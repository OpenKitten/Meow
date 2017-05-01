//
//  Meow.swift
//  Meow
//
//  Created by Robbert Brandsma on 03-01-17.
//
//

import MongoKitten
import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// The main object, keeps track of the database
public enum Meow {
    /// The database object
    public static var database: MongoKitten.Database!
    
    /// Initializes the static Meow database state with a MongoKitten.Database
    public static func `init`(_ db: MongoKitten.Database) {
        print("🐈 Init")
        Meow.database = db
        Meow.pool = ObjectPool()
    }
    
    /// Initializes the static Meow database state with a MongoKitten.Database from a connection string
    public static func `init`(_ connectionString: String) throws {
        Meow.init(try Database(connectionString))
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
    }
    
    public static var pool: ObjectPool!
    
    public class ObjectPool {
        private let objectPoolQueue = DispatchQueue(label: "org.openkitten.meow.objectPool", qos: .userInteractive)
        
        fileprivate init() {
            atexit { Meow.pool.beforeExit() }
        }
        
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
        
        private var storage = WeakDictionary<ObjectId, AnyObject>(minimumCapacity: 1000)
        private var unsavedObjectIds = Set<ObjectId>()
        private var invalidatedObjectIds = Set<ObjectId>()
        
        public func hello(_ henk: Any? = nil) {
            print(Thread.callStackSymbols)
        }
        
        public func newObjectId() -> ObjectId {
            let id = ObjectId()
            
            objectPoolQueue.sync {
                _ = unsavedObjectIds.insert(id)
            }
            
            return id
        }
        
        /// TODO: Make this thread-safe
        public func instantiateIfNeeded<M : BaseModel>(type: M.Type, document: Document) throws -> M {
            guard let id = ObjectId(document["_id"]) else {
                throw Error.missingOrInvalidValue(key: "_id")
            }
            
            var existingInstance: M?
                
            objectPoolQueue.sync {
                existingInstance = storage[id] as? M
            }
            
            if let existingInstance = existingInstance {
                print("🐈 Returning \(existingInstance) from pool")
                return existingInstance
            }
            
            let instance = try M(restoring: document)
            print("🐈 Returning fresh instance \(instance)")
            self.pool(instance)
            return instance
        }
        
        public func pool<M: BaseModel>(_ instance: M) {
            var current: AnyObject?
            
            objectPoolQueue.sync {
                current = storage[instance._id]
            }
            
            if let current = current {
                assert(current === instance, "two model instances with the same _id is invalid")
            } else {
                print("🐈 Pooling \(instance)")
                objectPoolQueue.sync {
                    if let index = unsavedObjectIds.index(of: instance._id) {
                        unsavedObjectIds.remove(at: index)
                    }
                }
            }
            
            objectPoolQueue.sync {
                // Only pool it if the instance is not invalidated
                if !invalidatedObjectIds.contains(instance._id) {
                    storage[instance._id] = instance
                }
            }
        }
        
        /// Invalidates the given ObjectId. Called when removing an object
        internal func invalidate(_ id: ObjectId) {
            objectPoolQueue.sync {
                // remove the instance from the pool
                storage[id] = nil
                invalidatedObjectIds.insert(id)
            }
        }
        
        public func free(_ id: ObjectId) {
            objectPoolQueue.sync {
                if let index = unsavedObjectIds.index(of: id) {
                    print("🐈 Unregistering ObjectId \(id)")
                    unsavedObjectIds.remove(at: index)
                }
            }
        }
        
        /// Returns if `instance` is currently in the pool
        public func isPooled<M: BaseModel>(_ instance: M) -> Bool {
            return objectPoolQueue.sync {
                return storage[instance._id] != nil
            }
        }
        
        public func handleDeinit<M: BaseModel>(_ instance: M) {
            do {
                try instance.save()
            } catch {
                print("🐈 Error while saving \(type(of: instance)) \(instance._id) in deinit: \(error)")
                assertionFailure()
            }
            print("🐈 Unpooling \(instance)")
            
            objectPoolQueue.sync {
                storage[instance._id] = nil
                
                // remove if invalidated to free up memory:
                invalidatedObjectIds.remove(instance._id)
            }
        }
    }
}
