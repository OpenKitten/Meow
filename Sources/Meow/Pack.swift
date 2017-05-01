//
//  Pack.swift
//  Meow
//
//  Created by Robbert Brandsma on 27-04-17.
//
//

import BSON
import MongoKitten

fileprivate func _unpack<S : Serializable>(_ key: String, from primitive: Primitive?) throws -> S {
    if let M = S.self as? BaseModel.Type {
        guard let document = primitive as? Document, let ref = DBRef(document, inDatabase: Meow.database) else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        guard let instance = try M.findOne("_id" == ref.id) else {
            throw Meow.Error.brokenReference(in: [ref])
        }
        
        return instance as! S
    } else {
        guard let primitive = primitive else {
            throw Meow.Error.missingValue(key: key)
        }
        
        return try S(restoring: primitive)
    }
}

fileprivate func _pack(_ serializable: Serializable?) -> Primitive? {
    if let serializable = serializable as? BaseModel {
        return DBRef(referencing: serializable._id, inCollection: type(of: serializable).collection)
    } else {
        return serializable?.serialize()
    }
}

extension Document {
    public func unpack<S : Serializable>(_ key: String) throws -> S {
        return try _unpack(key, from: self[key])
    }
    
    public mutating func pack(_ serializable: Serializable?, as key: String) {
        self[key] = _pack(serializable)
    }
}

extension Document {
    public func unpack<S : Serializable>(_ key: String) throws -> [S] {
        guard let array = self[key] as? Document, array.validatesAsArray() else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        return try array.arrayValue.map { try _unpack(key, from: $0) }
    }
    
    public mutating func pack(_ serializables: [Serializable], as key: String) {
        self[key] = serializables.map { _pack($0) }
    }
}
