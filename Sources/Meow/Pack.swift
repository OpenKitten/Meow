import BSON
import MongoKitten

/// Unpacks a value from a primitive
fileprivate func _unpack<S : Serializable>(_ key: String, from primitive: Primitive?) throws -> S {
    if let M = S.self as? BaseModel.Type {
        guard let document = Document(primitive), let id = ObjectId(document["_id"]) else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        guard let instance = try M.findOne("_id" == id) else {
            throw Meow.Error.referenceError(id: id, type: M)
        }
        
        return instance as! S
    } else {
        guard let primitive = primitive else {
            throw Meow.Error.missingValue(key: key)
        }
        
        return try S(restoring: primitive, key: key)
    }
}

/// Packs a serializable into a primitive
fileprivate func _pack(_ serializable: Serializable?) -> Primitive? {
    if let serializable = serializable as? BaseModel {
        return [
            "_id": serializable._id,
            "_ref": type(of: serializable).collection.name
        ]
    } else {
        return serializable?.serialize()
    }
}

extension Document {
    /// Unpacks a value from this document
    public func unpack<S : Serializable>(_ key: String) throws -> S {
        return try _unpack(key, from: self[key])
    }
    
    /// Packs a value into this document
    public mutating func pack(_ serializable: Serializable?, as key: String) {
        self[key] = _pack(serializable)
    }
}

extension Document {
    /// Unpacks an array of a value from this Document
    ///
    /// - parameter key: The key in this Document to unpack
    public func unpack<S : Serializable>(_ key: String) throws -> [S] {
        guard let array = self[key] as? Document, array.validatesAsArray() else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        return try array.arrayValue.map { try _unpack(key, from: $0) }
    }
    
    /// Unpacks a set of a value from this Document
    ///
    /// - parameter key: The key in this Document to unpack
    public func unpack<S : Serializable>(_ key: String) throws -> Set<S> {
        return try Set(unpack(key) as [S])
    }
    
    /// Packs a sequence of values into this document as an array
    ///
    /// - parameter serializables: The serializable sequence to pack
    /// - parameter key: The key in this Document to pack into
    public mutating func pack<S : Sequence>(_ serializables: S?, as key: String) where S.Iterator.Element : Serializable {
        self[key] = serializables?.map { _pack($0) }
    }
    
    /// Packs a dictionary with a string for it's key into this Document
    ///
    /// - parameter serializables: The serializable dictionary to pack
    /// - parameter key: The key in this Document to pack into
    public mutating func pack<V: Serializable>(_ serializable: Dictionary<String, V>, as key: String) {
        let primitives: Document = serializable.map { key, value in
            return [key, value.serialize()]
            }.reduce([], +)
        
        self[key] = primitives
    }
    
    /// Unpacks a dictionary with a string for it's key from this Document
    ///
    /// - parameter key: The key in this Document to unpack
    public func unpack<V: Serializable>(_ key: String) throws -> Dictionary<String, V> {
        let doc = try self.unpack(key) as Document
        var dict = [String: V]()
        
        for key in doc.keys {
            dict[key] = try doc.unpack(key)
        }
        
        return dict
    }
    
    /// Unpacks a dictionary of [Serializable : Serializable] from this Document
    ///
    /// - parameter key: The key in this Document to unpack
    public func unpack<K: Hashable & Serializable, V: Serializable>(_ key: String) throws -> Dictionary<K, V> {
        let doc = try self.unpack(key) as Document
        
        var dict = [K: V]()
        
        let keys = try doc.unpack("keys") as [K]
        let values = try doc.unpack("values") as [V]
        
        guard keys.count == values.count else {
            throw Meow.Error.missingOrInvalidValue(key: key)
        }
        
        for i in 0..<keys.count {
            dict[keys[i]] = values[i]
        }
        
        return dict
    }
    
    /// Packs a dictionary of [Serializable : Serializable] into this Document
    ///
    /// - parameter serializables: The serializable dictionary to pack
    /// - parameter key: The key in this Document to unpack
    public mutating func pack<K: Hashable & Serializable, V: Serializable>(_ serializable: Dictionary<K, V>, as key: String) {
        self[key] = [
            "keys": serializable.keys.map { $0.serialize() },
            "values": serializable.values.map { $0.serialize() }
        ]
    }
}
