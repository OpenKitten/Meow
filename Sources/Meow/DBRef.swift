//
//  DBRef.swift
//  Tikcit
//
//  Created by Robbert Brandsma on 16-05-17.
//
//

import MongoKitten

extension DBRef : Serializable {
    public init(restoring source: BSON.Primitive) throws {
        self = try Meow.Helpers.requireValue(DBRef(source, inDatabase: Meow.database), keyForError: "DBRef")
    }
    
    public func serialize() -> Primitive {
        return self.documentValue
    }
}
