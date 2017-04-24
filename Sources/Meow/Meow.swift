//
//  Meow.swift
//  Meow
//
//  Created by Robbert Brandsma on 03-01-17.
//
//

import MongoKitten

/// The main object, keeps track of the database
public enum Meow {
    /// The database object
    public static var database: MongoKitten.Database!
    
    /// Initializes the static Meow database state with a MongoKitten.Database
    public static func `init`(_ db: MongoKitten.Database) {
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
            guard let val = val else {
                throw Error.missingOrInvalidValue(key: key)
            }
            
            return val
        }
    }
    
    /// Generic errors thrown by the generator
    public enum Error : Swift.Error {
        case missingOrInvalidValue(key: String)
        case referenceError(id: ObjectId, type: Model.Type)
        case undeletableObject(reason: String)
        case enumCaseNotFound(enum: String, name: String)
        case fileTooLarge(size: Int, maximum: Int)
    }
    
    public static var pool = ObjectPool()
    
    public class ObjectPool {
        fileprivate init() {}
        
        private var storage = WeakDictionary<ObjectId, AnyObject>(minimumCapacity: 1000)
        
        /// TODO: Make this thread-safe
        public func instantiateIfNeeded<M : ConcreteModel>(type: ConcreteModel.Type, document: Document) throws -> M {
            guard let id = ObjectId(document["_id"]) else {
                throw Error.missingOrInvalidValue(key: "_id")
            }
            
            if let existingInstance = storage[id] as? M {
                return existingInstance
            }
            
            return try M(document: document)
        }
        
        public func pool(_ instance: ConcreteModel) {
            if let current = storage[instance._id] {
                assert(current === instance, "two model instances with the same _id is invalid")
            }
            
            storage[instance._id] = instance
        }
        
        /// Returns if `instance` is currently in the pool
        public func isPooled(_ instance: ConcreteModel) -> Bool {
            return storage[instance._id] != nil
        }
    }
}
