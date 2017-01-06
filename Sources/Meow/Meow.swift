//
//  Meow.swift
//  Meow
//
//  Created by Robbert Brandsma on 03-01-17.
//
//

import MongoKitten

public enum Meow {
    public static var database: MongoKitten.Database!
    
    public static func `init`(_ db: MongoKitten.Database) {
        Meow.database = db
    }
    
    public static func `init`(_ connectionString: String) throws {
        Meow.init(try Database(mongoURL: connectionString))
    }
    
    public enum Helpers {
        public static func requireValue<T>(_ val: T?, keyForError key: String) throws -> T {
            guard let val = val else {
                throw Error.missingOrInvalidValue(key: key)
            }
            
            return val
        }
    }
    
    public enum Error : Swift.Error {
        case missingOrInvalidValue(key: String)
        case referenceError(id: ObjectId, type: Model.Type)
        case undeletableObject(reason: String)
    }
}
