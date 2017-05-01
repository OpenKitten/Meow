//
//  Pack.swift
//  Meow
//
//  Created by Robbert Brandsma on 27-04-17.
//
//

import BSON

extension Document {
    public func unpack<S : Serializable>(_ key: String) throws -> S {
        if let M = S.self as? Model.Type {
            guard let id = self[key] as? ObjectId else {
                throw Meow.Error.missingValue(key: key)
            }
            
            guard let instance = try M.findOne("_id" == id) else {
                throw Meow.Error.brokenReference(in: [id])
            }
            
            return instance as! S
        } else {
            guard let value = self[key] else {
                throw Meow.Error.missingValue(key: key)
            }
            
            return try S(restoring: value)
        }
    }
    
    public mutating func pack(_ serializable: Serializable?, as key: String) {
        if let serializable = serializable as? Model {
            self[key] = serializable._id
        } else {
            self[key] = serializable?.serialize()
        }
    }
}
