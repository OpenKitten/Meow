import MongoKitten
import Foundation
import Dispatch

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// The main object, keeps track of the database
public enum Meow {
    /// The database object
    public private(set) static var database: MongoKitten.Database!
    
    /// All Meow types
    internal static var types: [Any.Type]!
    
    /// Initializes the static Meow database state with a MongoKitten.Database
    public static func `init`(_ db: MongoKitten.Database, _ types: [Any.Type] = []) {
        print("🐈 Init")
        Meow.database = db
        Meow.types = types
        Meow.pool = ObjectPool()
        
        scheduleMaintenance()
    }
    
    /// Initializes the static Meow database state with a MongoKitten.Database from a connection string
    public static func `init`(_ connectionString: String, _ types: [Any.Type] = []) throws {
        Meow.init(try Database(connectionString), types)
    }
    
    /// Helpers for the generator
    public enum Helpers {
        /// Throws when the value is nil
        public static func requireValue<T>(_ val: T?, keyForError key: String) throws -> T {
            guard let val = val else {
                throw Error.missingOrInvalidValue(key: key)
            }
            
            return val
        }
    }
    
    /// Generic errors thrown by the generator
    public enum Error : Swift.Error {
        case missingOrInvalidValue(key: String)
        case missingValue(key: String)
        case referenceError(id: ObjectId, type: BaseModel.Type)
        case undeletableObject(reason: String)
        case enumCaseNotFound(enum: String, name: String)
        case fileTooLarge(size: Int, maximum: Int)
        case cannotDeserialize(type: Serializable.Type, source: BSON.Primitive?, expectedPrimitive: BSON.Primitive.Type)
        case brokenReference(in: [DBRef])
        case deletingMultiple(errors: [(ObjectId, Swift.Error)])
        case cannotValidate(reason: String)
        case infiniteReferenceLoop(type: BaseModel.Type, id: ObjectId)
    }
    
    /// An ObjectPool that is used to link models in-memory
    public static var pool: ObjectPool!
    
    internal static let maintenanceQueue = DispatchQueue(label: "org.openkitten.meow.maintenance", qos: .background)
    
    public static var maintenanceInterval: TimeInterval = 5
    public static var minimumAutosaveAge: TimeInterval = 5
    
    private static func maintenance() {
        print("🐈 Performing maintenance")
        
        do {
            Meow.pool.clean()
            try Meow.pool.autoSave()
        } catch {
            print("🐈❗ Error while performing maintenance")
            print(error)
            assertionFailure("\(error)")
        }
        
        // Schedule next maintenance
        scheduleMaintenance()
    }
    
    private static func scheduleMaintenance() {
        maintenanceQueue.asyncAfter(deadline: DispatchTime(secondsFromNow: maintenanceInterval), execute: Meow.maintenance)
    }
    
    /// The ObjectPool is used to hold references to models to link them in-memory
    ///
    /// It also functions as the intelligent brain behind autosaving, manages ObjectId's amongst other functions.
    public class ObjectPool {
        /// The queue used to prevent crashes in mutations
        private let objectPoolMutationQueue = DispatchQueue(label: "org.openkitten.meow.objectPool", qos: .userInteractive)
        
        fileprivate init() {
            // Save the database contents before exiting
            atexit { Meow.pool.beforeExit() }
        }
        
        /// Saves the database contents before exiting
        private func beforeExit() {
            print("🐈 Performing pre-exit save")
            
            for (_, object) in storage {
                guard let instance = object as? BaseModel else {
                    continue
                }
                
                do {
                    try instance.save()
                } catch {
                    print("🐈 Error while performing pre-exit save on \(instance)")
                    assertionFailure()
                }
            }
            
            for id in unsavedObjectIds {
                print("🐈 WARNING: An ObjectId \(id) was generated, but the object was not saved. This is probably because the object was not deallocated by ARC before program exit. The data has been lost, as Meow does not have access to it. To solve this, do not use models as global or top level variables. If you do use models as global or top level objects, make sure to call save() manually or add it to the object pool yourself using Meow.pool.pool(instance), for example in the initializer of the model.")
                assertionFailure("This will crash on debug, but not on release builds.")
            }
        }
        
        /// The internal storage that's used to hold metadata and references to objects
        internal private(set) var storage = [ObjectId: (instance: Weak<AnyObject>, instantiation: Date, hash: Int?)](minimumCapacity: 1000)
        
        /// A set of unsaved ObjectIds that need to be saves, still
        private var unsavedObjectIds = Set<ObjectId>()
        
        /// A set of entity's ObjectIds that are invalidated because they were removed
        private var invalidatedObjectIds = Set<ObjectId>()
        
        /// A set of entity's ObjectIds that are currently being instantiated
        private var currentlyInstantiating = Set<ObjectId>()
        
        /// Generated a new ObjectId
        public func newObjectId() -> ObjectId {
            let id = ObjectId()
            
            objectPoolMutationQueue.sync {
                _ = unsavedObjectIds.insert(id)
            }
            
            return id
        }
        
        /// Instantiates a model from a Document unless the model is alraedy in-memory
        public func instantiateIfNeeded<M : BaseModel>(type: M.Type, document: Document) throws -> M {
            guard let id = ObjectId(document["_id"]) else {
                throw Error.missingOrInvalidValue(key: "_id")
            }
            
            var existingInstance: M?
            
            objectPoolMutationQueue.sync {
                existingInstance = storage[id]?.instance.value as? M
            }
            
            if let existingInstance = existingInstance {
                print("🐈 Returning \(existingInstance) from pool")
                return existingInstance
            }
            
            guard !currentlyInstantiating.contains(id) else {
                throw Meow.Error.infiniteReferenceLoop(type: M.self, id: id)
            }
            
            currentlyInstantiating.insert(id)
            
            let instance = try M(restoring: document)
            print("🐈 Returning fresh instance \(instance)")
            
            currentlyInstantiating.remove(id)
            
            self.pool(instance, hash: document.meowHash)
            return instance
        }
        
        /// Stored an entity in the pool
        public func pool<M: BaseModel>(_ instance: M, hash: Int? = nil) {
            var current: AnyObject?
            
            objectPoolMutationQueue.sync {
                current = storage[instance._id]?.instance.value
            }
            
            if let current = current {
                assert(current === instance as AnyObject, "two model instances with the same _id is invalid")
                return
            } else {
                print("🐈 Pooling \(instance)")
                objectPoolMutationQueue.sync {
                    if let index = unsavedObjectIds.index(of: instance._id) {
                        unsavedObjectIds.remove(at: index)
                    }
                }
            }
            
            objectPoolMutationQueue.sync {
                // Only pool it if the instance is not invalidated
                if !invalidatedObjectIds.contains(instance._id) {
                    storage[instance._id] = (instance: Weak(instance as AnyObject), instantiation: Date(), hash: hash)
                }
            }
        }
        
        internal func existingHash(for instance: BaseModel) -> Int? {
            return storage[instance._id]?.hash
        }
        
        internal func updateHash(for instance: BaseModel, with newHash: Int?) {
            storage[instance._id]?.hash = newHash
        }
        
        /// Invalidates the given ObjectId. Called when removing an object
        internal func invalidate(_ id: ObjectId) {
            objectPoolMutationQueue.sync {
                // remove the instance from the pool
                storage[id] = nil
                invalidatedObjectIds.insert(id)
            }
        }
        
        /// Frees an objectId fromthe unsavedObjectIds
        public func free(_ id: ObjectId) {
            objectPoolMutationQueue.sync {
                if let index = unsavedObjectIds.index(of: id) {
                    print("🐈 Unregistering ObjectId \(id)")
                    unsavedObjectIds.remove(at: index)
                }
            }
        }
        
        /// Returns if `instance` is currently in the pool
        public func isPooled<M: BaseModel>(_ instance: M) -> Bool {
            return objectPoolMutationQueue.sync {
                return storage[instance._id] != nil
            }
        }
        
        /// Saves an object after being deinitialized
        public func handleDeinit<M: BaseModel>(_ instance: M) {
            do {
                try instance.save()
            } catch {
                print("🐈 Error while saving \(type(of: instance)) \(instance._id) in deinit: \(error)")
                assertionFailure()
            }
            print("🐈 Unpooling \(instance)")
            
            objectPoolMutationQueue.sync {
                storage[instance._id] = nil
                
                // remove if invalidated to free up memory:
                invalidatedObjectIds.remove(instance._id)
            }
        }
        
        /// The amount of pooled objects
        public var count: Int {
            self.clean()
            return objectPoolMutationQueue.sync {
                return storage.count
            }
        }
        
        /// Removes deallocated entries from the pool
        public func clean() {
            return objectPoolMutationQueue.sync {
                for (id, val) in storage {
                    if val.instance.value == nil {
                        storage[id] = nil
                    }
                }
            }
        }
        
        /// Handles automatically saving models so they don't get lost when the server randomly crashes/shuts down
        fileprivate func autoSave() throws {
            let oldObjects = storage.filter({ $0.value.instantiation.timeIntervalSinceNow < -(minimumAutosaveAge) })
            for (_, val) in oldObjects {
                try (val.instance.value as? BaseModel)?.save()
            }
        }
    }
}
