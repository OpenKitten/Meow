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
        guard let value = self[key] else {
            throw Meow.Error.missingValue(key: key)
        }
        
        return try S(restoring: value)
    }
    
    public mutating func pack(_ serializable: Serializable?, as key: String) {
        self[key] = serializable?.serialize()
    }
}
