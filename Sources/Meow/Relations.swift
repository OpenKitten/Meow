//
//  Relations.swift
//  Meow
//
//  Created by Joannis Orlandos on 01/05/2017.
//
//

import MongoKitten

public struct Reference<M: Model> : Serializable, Hashable {
    let reference: ObjectId
    
    public static func ==(lhs: Reference<M>, rhs: Reference<M>) -> Bool {
        return lhs.reference == rhs.reference
    }
    
    public var hashValue: Int {
        return reference.hashValue
    }
    
    public init(to entity: M) {
        reference = entity._id
    }
    
    public init(restoring source: Primitive) throws {
        let id = try Meow.Helpers.requireValue(ObjectId(source), keyForError: "primitive ObjectId")
        
        self.reference = id
    }
    
    public func serialize() -> Primitive {
        return reference
    }
    
    public func resolve() throws -> M {
        guard let referenced = try M.findOne("_id" == reference) else {
            throw Meow.Error.referenceError(id: reference, type: M.self)
        }
        
        return referenced
    }
}

extension Document {
    public func unpack<M: Model>(_ key: String) throws -> Set<Reference<M>> {
        return Set(try unpack(key) as [Reference<M>])
    }
    
    public mutating func pack<M: Model>(_ serializable: Set<Reference<M>>, as key: String) {
        self[key] = serializable.map { $0.reference }
    }
    
    public func unpack<K: Hashable & Serializable, V: Serializable>(_ key: String) throws -> Dictionary<K, V> {
        let doc = try self.unpack(key) as Document
        
        guard doc.validatesAsArray(), doc.count % 2 == 0 else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        var i = 0
        let array = doc.arrayValue
        
        var dict = Dictionary<K, V>()
        
        while i < doc.count {
            defer { i += 2}
            
            let key = try K.init(restoring: array[i])
            let value = try V.init(restoring: array[i + 1])
            
            dict[key] = value
        }
        
        return dict
    }
    
    public mutating func pack<K: Hashable & Serializable, V: Serializable>(_ serializable: Dictionary<K, V>, as key: String) {
        let primitives: Document = serializable.map { key, value in
            return [key.serialize(), value.serialize()]
            }.reduce([], +)
        
        self[key] = primitives
    }
}
