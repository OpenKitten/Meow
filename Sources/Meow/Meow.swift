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
    
    /// Initializes the static Meow database state with a MongoKitten.Database
    public static func `init`(_ db: MongoKitten.Database) {
        Meow.log("Init")
        Meow.database = db
    }
    
    /// Initializes the static Meow database state with a MongoKitten.Database from a connection string
    public static func `init`(_ connectionString: String) throws {
        Meow.init(try Database(connectionString))
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
        case infiniteRecursiveReference(from: _Model.Type, to: _Model.Type)
        
        /// The value for the given key is missing, or invalid
        case missingOrInvalidValue(key: String, expected: Any.Type, got: Any?)
        
        /// The value is invalid
        case invalidValue(key: String, reason: String)
        
        /// A reference to `type` with id `id` cannot be resolved
        case referenceError(id: ObjectId, type: _Model.Type)
        
        /// An object cannot be deleted, because of `reason`
        case undeletableObject(reason: String)
        
        /// A file cannot be stored because it exceeds the maximum size
        case fileTooLarge(size: Int, maximum: Int)
        
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
        case infiniteReferenceLoop(type: _Model.Type, id: ObjectId)
        
        /// The file cannot be found in GridFS
        case brokenFileReference(ObjectId)
    }
    
    /// The Object Pool instance. For more information, look at the `ObjectPool` documentation.
    public static let pool = ObjectPool()
    
//    public static var middleware = [TransactionMiddleware]()
    
    /// The ObjectPool is used to hold references to models to link them in-memory
    ///
    /// It also functions as the intelligent brain behind autosaving, manages ObjectId's amongst other functions.
    public class ObjectPool {
        private class RunningInstantiation {
            enum Result {
                case success(_Model)
                case error(Swift.Error)
            }
            
            var thread = Thread.current
            private var lock = NSLock()
            var result: Result?
            
            init() {
                lock.lock()
            }
            
            func `do`<M : _Model>(_ closure: () throws -> (M)) throws -> M {
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
            
            func await() throws -> _Model {
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
        
        private var strongReferences = [_Model]()
        
        /// The lock used to prevent crashes in mutations
        private var objectPoolMutationLock = NSRecursiveLock()
        
        /// The internal storage that's used to hold metadata and references to objects
        internal private(set) var storage = [ObjectId: (instance: Weak<AnyObject>, instantiation: Date)](minimumCapacity: 1000)
        
        /// A set of entity's ObjectIds that are invalidated because they were removed
        private var invalidatedObjectIds = Set<ObjectId>()
        
        /// A set of entity's ObjectIds that are currently being instantiated
        private var currentlyInstantiating = [ObjectId: RunningInstantiation]()
        
        /// Ghosted instances
        private var ghosts = Set<ObjectIdentifier>()
        
        /// Turns the `instance` into a ghost. It will not be saved again.
        public func ghost(_ instance: _Model) {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            let id = ObjectIdentifier(instance)
            self.ghosts.insert(id)
        }
        
        public func isGhost(_ instance: _Model) -> Bool {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            let id = ObjectIdentifier(instance)
            return ghosts.contains(id)
        }
        
        /// Instantiates a model from a Document unless the model is already in-memory
        public func instantiateIfNeeded<M : _Model>(type: M.Type, document: Document) throws -> M {
            guard let id = ObjectId(document["_id"]) else {
                throw Error.missingOrInvalidValue(key: "_id", expected: ObjectId.self, got: document["_id"])
            }
            
            objectPoolMutationLock.lock()
            let existingInstance: M? = storage[id]?.instance.value as? M
            objectPoolMutationLock.unlock()
            
            if let existingInstance = existingInstance {
                Meow.log("Returning \(existingInstance) from pool")
                return existingInstance
            }
            
            let instantiation: RunningInstantiation = try {
                objectPoolMutationLock.lock()
                defer { objectPoolMutationLock.unlock() }
                
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
                }()
            
            if instantiation.thread != Thread.current {
                Meow.log("Waiting for instance from other thread")
                let instance = try instantiation.await() as! M
                Meow.log("Returning \(instance) from instantiation in other thread")
                return instance
            }
            
            return try instantiation.do {
                let decoder = M.decoder
                let instance = try decoder.decode(M.self, from: document)
                Meow.log("Returning fresh instance \(instance)")
 
                objectPoolMutationLock.lock()
                currentlyInstantiating[id] = nil
                objectPoolMutationLock.unlock()
                
                return instance
            }
        }
        
        public func getPooledInstance<M: Model>(withIdentifier id: ObjectId) -> M? {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            return storage[id]?.instance.value as? M
        }
        
        /// Stored an entity in the pool
        public func pool<M: Model>(_ instance: M) {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            let current = storage[instance._id]?.instance.value
            
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
            
            if let current = current {
                assert(current === instance, "two model instances with the same _id is invalid")
                return
            } else {
                Meow.log("Pooling \(instance)")
            }
            
            // Only pool it if the instance is not invalidated
            if !invalidatedObjectIds.contains(instance._id) {
                storage[instance._id] = (instance: Weak(instance), instantiation: Date())
            }
            
        }
        
        /// Invalidates the given ObjectId. Called when removing an object
        internal func invalidate(_ id: ObjectId) {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            // remove the instance from the pool
            self.storage[id] = nil
            self.invalidatedObjectIds.insert(id)
        }
        
        /// Returns if `instance` is currently in the pool
        public func isPooled<M: Model>(_ instance: M) -> Bool {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            return storage[instance._id] != nil
        }
        
        /// The amount of pooled objects
        public var count: Int {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
            self.clean()
            return storage.count
        }
        
        /// Removes deallocated entries from the pool
        @discardableResult
        public func clean() -> Int {
            objectPoolMutationLock.lock()
            defer { objectPoolMutationLock.unlock() }
            
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
}

