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
    public static var shouldLog = false
    
    public static func log(_ item: @autoclosure () -> (Any)) {
        guard Meow.shouldLog else { return }
        
        print("🐈 ", item())
    }
    
    /// The database object
    public private(set) static var database: MongoKitten.Database!
    
    /// All Meow types
    public private(set) static var types: [Any.Type]!
    
    /// Initializes the static Meow database state with a MongoKitten.Database
    public static func `init`(_ db: MongoKitten.Database, _ types: [Any.Type]) {
        Meow.log("Init")
        Meow.database = db
        Meow.types = types
        
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
            guard let theVal = val else {
                throw Error.missingOrInvalidValue(key: key, expected: T.self, got: val)
            }
            
            return theVal
        }
    }
    
    /// Generic errors thrown by the generator
    public enum Error : Swift.Error {
        case infiniteRecursiveReference(from: BaseModel.Type, to: BaseModel.Type)
        
        /// The value for the given key is missing, or invalid
        case missingOrInvalidValue(key: String, expected: Any.Type, got: Any?)
        
        /// The value is invalid
        case invalidValue(key: String, reason: String)
        
        /// A reference to `type` with id `id` cannot be resolved
        case referenceError(id: ObjectId, type: BaseModel.Type)
        
        /// An object cannot be deleted, because of `reason`
        case undeletableObject(reason: String)
        
        /// The given case for the `enum` could not be found while deserializing an object
        case enumCaseNotFound(enum: String, name: String)
        
        /// A file cannot be stored because it exceeds the maximum size
        case fileTooLarge(size: Int, maximum: Int)
        
        /// The serializable `type` cannot be deserialized from `source` because it is not `expectedPrimtive`
        case cannotDeserialize(type: Serializable.Type, source: BSON.Primitive?, expectedPrimitive: BSON.Primitive.Type)
        
        /// The given DBRef is not valid
        case brokenReference(in: DBRef)
        
        /// One or more errors occurred while mass-deleting objects. The `errors` array contains the specific object identifier and error pairs.
        case deletingMultiple(errors: [(ObjectId, Swift.Error)])
        
        /// Meow was not able to validate the database, because `reason`
        case cannotValidate(reason: String)
        
        /// An infinite reference loop has occurred while trying to deserialize an object.
        /// This happens if you reference objects like this: `a` -> `b` -> `a`
        ///
        /// That's bad practice, both under ARC and in Meow. Meow is not able to instantiate `a`
        /// nor `b` in the above example, because it would create an infinite loop while trying to
        /// resolve the references.
        ///
        /// You can solve the infinite reference loop by making one of the references lazy, by
        /// using the `Reference` type. So instead of `var myReference: MyModel`, you would use
        /// `var myReference: Reference<MyModel>`.
        case infiniteReferenceLoop(type: BaseModel.Type, id: ObjectId)
        
        /// The file cannot be found in GridFS
        case brokenFileReference(ObjectId)
    }
    
    /// The Object Pool instance. For more information, look at the `ObjectPool` documentation.
    public static let pool = ObjectPool()
    
    internal static let maintenanceQueue = DispatchQueue(label: "org.openkitten.meow.maintenance", qos: .background)
    
    /// The time interval, in seconds, at which the maintenance loop runs. Defaults to 5.
    public static var maintenanceInterval: TimeInterval = 5
    
    /// The minimum age an object must have before it can be autosaved, in seconds. Defualts to 5.
    public static var minimumAutosaveAge: TimeInterval = 5
    
    private static func maintenance() {
        Meow.log("Performing maintenance")
        
        do {
            Meow.pool.clean()
            try Meow.pool.autoSave()
        } catch {
            Meow.log("❗ Error while performing maintenance")
            Meow.log(error)
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
        private class RunningInstantiation {
            enum Result {
                case success(BaseModel)
                case error(Swift.Error)
            }
            
            var thread = Thread.current
            private var lock = NSLock()
            var result: Result?
            
            init() {
                lock.lock()
            }
            
            func `do`<M : BaseModel>(_ closure: () throws -> (M)) throws -> M {
                do {
                    let m = try closure()
                    result = .success(m)
                    lock.unlock()
                    return m
                } catch {
                    result = .error(error)
                    lock.unlock()
                    throw error
                }
            }
            
            func await() throws -> BaseModel {
                lock.lock()
                lock.unlock()
                
                switch result! {
                case .success(let m): return m
                case .error(let error): throw error
                }
            }
            
            deinit {
                if result == nil {
                    lock.unlock()
                }
            }
        }
        
        /// The amount of objects to keep strong references to
        public var strongReferenceAmount = 0
        
        private var strongReferences = [BaseModel]()
        
        /// The queue used to prevent crashes in mutations
        private let objectPoolMutationQueue = DispatchQueue(label: "org.openkitten.meow.objectPool", qos: .userInteractive)
        
        fileprivate init() {
            // Save the database contents before exiting
            atexit { Meow.pool.beforeExit() }
        }
        
        /// Saves the database contents before exiting
        private func beforeExit() {
            Meow.log("Performing pre-exit save")
            
            for (_, object) in storage {
                guard let instance = object as? BaseModel else {
                    continue
                }
                
                do {
                    try instance.save()
                } catch {
                    Meow.log("Error while performing pre-exit save on \(instance)")
                    assertionFailure()
                }
            }
            
            for id in unsavedObjectIds {
                let message = "WARNING: An ObjectId \(id.hexString) was generated, but the object was not saved. This is probably because the object was not deallocated by ARC before program exit. The data has been lost, as Meow does not have access to it. To solve this, do not use models as global or top level variables. If you do use models as global or top level objects, make sure to call save() manually or add it to the object pool yourself using Meow.pool.pool(instance), for example in the initializer of the model."
                Meow.log(message)
                assertionFailure(message)
                assertionFailure("This will crash on debug, but not on release builds.")
            }
        }
        
        /// The internal storage that's used to hold metadata and references to objects
        internal private(set) var storage = [ObjectId: (instance: Weak<AnyObject>, instantiation: Date, hash: Int?)](minimumCapacity: 1000)
        
        /// A set of unsaved ObjectIds that need to be saved, still
        private var unsavedObjectIds = Set<ObjectId>()
        
        /// A set of entity's ObjectIds that are invalidated because they were removed
        private var invalidatedObjectIds = Set<ObjectId>()
        
        /// A set of entity's ObjectIds that are currently being instantiated
        private var currentlyInstantiating = [ObjectId: RunningInstantiation]()
        
        /// Ghosted instances
        private var ghosts = Set<ObjectIdentifier>()
        
        /// Generated a new ObjectId
        public func newObjectId() -> ObjectId {
            let id = ObjectId()
            
            objectPoolMutationQueue.sync {
                _ = unsavedObjectIds.insert(id)
            }
            
            return id
        }
        
        /// Turns the `instance` into a ghost. It will not be saved again.
        public func ghost(_ instance: BaseModel) {
            objectPoolMutationQueue.async {
                self.ghosts.insert(ObjectIdentifier(instance))
            }
        }
        
        public func isGhost(_ instance: BaseModel) -> Bool {
            return objectPoolMutationQueue.sync {
                return ghosts.contains(ObjectIdentifier(instance))
            }
        }
        
        /// Instantiates a model from a Document unless the model is alraedy in-memory
        public func instantiateIfNeeded<M : BaseModel>(type: M.Type, document: Document) throws -> M {
            guard let id = ObjectId(document["_id"]) else {
                throw Error.missingOrInvalidValue(key: "_id", expected: ObjectId.self, got: document["_id"])
            }
            
            var existingInstance: M?
            
            objectPoolMutationQueue.sync {
                existingInstance = storage[id]?.instance.value as? M
            }
            
            if let existingInstance = existingInstance {
                Meow.log("Returning \(existingInstance) from pool")
                return existingInstance
            }
            
            let instantiation: RunningInstantiation = try objectPoolMutationQueue.sync {
                let instantiation = currentlyInstantiating[id]
                guard instantiation == nil || instantiation!.thread != Thread.current else {
                    throw Meow.Error.infiniteReferenceLoop(type: M.self, id: id)
                }
                
                if let instantiation = instantiation {
                    return instantiation
                } else {
                    let instantiation = RunningInstantiation()
                    currentlyInstantiating[id] = instantiation
                    return instantiation
                }
            }
            
            if instantiation.thread != Thread.current {
                Meow.log("Waiting for instance from other thread")
                let instance = try instantiation.await() as! M
                Meow.log("Returning \(instance) from instantiation in other thread")
                return instance
            }
            
            return try instantiation.do {
                let instance = try M(restoring: document, key: "")
                Meow.log("Returning fresh instance \(instance)")
                
                self.pool(instance, hash: document.meowHash)
                
                objectPoolMutationQueue.sync {
                    currentlyInstantiating[id] = nil
                }
                
                return instance
            }
        }
        
        public func getPooledInstance<M: BaseModel>(withIdentifier id: ObjectId) -> M? {
            return objectPoolMutationQueue.sync {
                return storage[id]?.instance.value as? M
            }
        }
        
        /// Stored an entity in the pool
        public func pool<M: BaseModel>(_ instance: M, hash: Int? = nil) {
            var current: AnyObject?
            
            objectPoolMutationQueue.sync {
                current = storage[instance._id]?.instance.value
                
                // remove old strong reference
                if let current = current, let index = self.strongReferences.index(where: { $0 === current }) {
                    self.strongReferences.remove(at: index)
                }
                
                // keep a strong reference
                if self.strongReferenceAmount > 0 {
                    self.strongReferences.insert(instance, at: 0)
                }
                
                // clean up strong references
                if self.strongReferences.count > self.strongReferenceAmount {
                    self.strongReferences.removeLast(self.strongReferences.count - self.strongReferenceAmount)
                }
            }
            
            if let current = current {
                assert(current === instance.object, "two model instances with the same _id is invalid")
                return
            } else {
                Meow.log("Pooling \(instance)")
                objectPoolMutationQueue.sync {
                    if let index = unsavedObjectIds.index(of: instance._id) {
                        unsavedObjectIds.remove(at: index)
                    }
                }
            }
            
            objectPoolMutationQueue.sync {
                // Only pool it if the instance is not invalidated
                if !invalidatedObjectIds.contains(instance._id) {
                    storage[instance._id] = (instance: Weak(instance.object), instantiation: Date(), hash: hash ?? storage[instance._id]?.hash /* existing hash fallback */)
                }
            }
        }
        
        internal func existingHash(for instance: BaseModel) -> Int? {
            return objectPoolMutationQueue.sync {
                return storage[instance._id]?.hash
            }
        }
        
        internal func updateHash(for instance: BaseModel, with newHash: Int?) {
            // we don't return any value here, and the pool is accessed only from this queue, so this is a safe async operation
            objectPoolMutationQueue.async {
                self.storage[instance._id]?.hash = newHash
            }
        }
        
        /// Invalidates the given ObjectId. Called when removing an object
        internal func invalidate(_ id: ObjectId) {
            // we don't return any value here, and the pool is accessed only from this queue, so this is a safe async operation
            objectPoolMutationQueue.async {
                // remove the instance from the pool
                self.storage[id] = nil
                self.invalidatedObjectIds.insert(id)
            }
        }
        
        /// Frees an objectId fromthe unsavedObjectIds
        public func free(_ id: ObjectId) {
            // we don't return any value here, and the pool is accessed only from this queue, so this is a safe async operation
            objectPoolMutationQueue.async {
                if let index = self.unsavedObjectIds.index(of: id) {
                    Meow.log("Unregistering ObjectId \(id)")
                    self.unsavedObjectIds.remove(at: index)
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
            defer {
                objectPoolMutationQueue.async {
                    self.ghosts.remove(ObjectIdentifier(instance))
                }
            }
            
            do {
                if !invalidatedObjectIds.contains(instance._id) {
                    try instance.save()
                }
            } catch {
                Meow.log("Error while saving \(type(of: instance)) \(instance._id) in deinit: \(error)")
                assertionFailure()
            }
            
            Meow.log("Unpooling \(instance)")
            
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
        @discardableResult
        public func clean() -> Int {
            return objectPoolMutationQueue.sync {
                var cleanedCount = 0
                
                for (id, val) in storage {
                    if val.instance.value == nil {
                        storage[id] = nil
                        cleanedCount += 1
                    }
                }
                
                return cleanedCount
            }
        }
        
        /// Handles automatically saving models so they don't get lost when the server randomly crashes/shuts down
        fileprivate func autoSave() throws {
            let oldObjects = objectPoolMutationQueue.sync {
                return storage.filter({ $0.value.instantiation.timeIntervalSinceNow < -(minimumAutosaveAge) })
            }
            
            for (_, val) in oldObjects {
                try (val.instance.value as? BaseModel)?.save()
            }
        }
    }
}

fileprivate extension BaseModel {
    var object: AnyObject {
        #if os(Linux)
            return self as! AnyObject
        #else
            return self as AnyObject
        #endif
    }
}
