import BSON
import MongoKitten

public protocol PackableSequence : Sequence {
    associatedtype Element
    init<S>(meowSequence: S) where S : PackableSequence, S.Iterator.Element == Element
}

extension Array : PackableSequence {
    public init<S>(meowSequence: S) where S : PackableSequence, S.Iterator.Element == Element {
        self.init(meowSequence)
    }
}

extension Set : PackableSequence {
    public init<S>(meowSequence: S) where S : PackableSequence, S.Iterator.Element == Element {
        self.init(meowSequence)
    }
}

/// Unpacks a value from a primitive
fileprivate func _unpack<S : Serializable>(_ key: String, from primitive: Primitive?) throws -> S {
    if let M = S.self as? BaseModel.Type {
        guard let id = ObjectId(primitive) ?? ObjectId(primitive["_id"]) ?? ObjectId(primitive[0]["_id"]) else {
            throw Meow.Error.missingOrInvalidValue(key: key, expected: ObjectId.self, got: primitive)
        }
        
        guard let instance = try M.findOne("_id" == id) else {
            throw Meow.Error.referenceError(id: id, type: M)
        }
        
        return instance as! S
    } else {
        guard let primitive = primitive else {
            throw Meow.Error.missingOrInvalidValue(key: key, expected: S.self, got: nil)
        }
        
        return try S(restoring: primitive, key: key)
    }
}

/// Packs a serializable into a primitive
fileprivate func _pack(_ serializable: Serializable?) -> Primitive? {
    if let serializable = serializable as? BaseModel {
        return serializable._id
    } else {
        return serializable?.serialize()
    }
}

extension Document {
    /// Unpacks a value from this document
    public func unpack<S : Serializable>(_ key: String, default: S? = nil) throws -> S {
        if let `default` = `default`, !meowHasValue(key) {
            return `default`
        }
        
        return try _unpack(key, from: self[key])
    }
    
    /// Unpacks an optional value from this document
    public func unpack<S : Serializable>(_ key: String) throws -> S? {
        if !self.meowHasValue(key) {
            return nil
        }
        
        do {
            return try _unpack(key, from: self[key])
        } catch Meow.Error.referenceError {
            return nil
        }
    }
    
    /// Packs a value into this document
    public mutating func pack(_ serializable: Serializable?, as key: String) {
        self[key] = _pack(serializable)
    }
}

extension Document {
    /// Unpacks a sequence of a value from this Document
    ///
    /// - parameter key: The key in this Document to unpack
    /// - parameter default: The default fallback value
    public func unpack<Seq : PackableSequence, Ser : Serializable>(_ key: String, default: Seq? = nil) throws -> Seq where Seq.Element == Ser {
        if let `default` = `default`, !meowHasValue(key) {
            return `default`
        }
        
        guard let array = self[key] as? Document, array.validatesAsArray() else {
            throw Meow.Error.missingOrInvalidValue(key: key, expected: Document.self, got: self[key])
        }
        
        let unpackedArray: [Ser] = try array.arrayValue.map { try _unpack(key, from: $0) }
        
        return Seq(meowSequence: unpackedArray)
    }
    
    /// Unpacks an optional sequence of a value from this document
    public func unpack<Seq : PackableSequence, Ser : Serializable>(_ key: String) throws -> Seq? where Seq.Element == Ser {
        if !meowHasValue(key) {
            return nil
        }
        
        return try self.unpack(key, default: nil)
    }
    
    /// Packs a sequence of values into this document as an array
    ///
    /// - parameter serializables: The serializable sequence to pack
    /// - parameter key: The key in this Document to pack into
    public mutating func pack<S : PackableSequence>(_ serializables: S?, as key: String) where S.Iterator.Element : Serializable {
        if let serializables = serializables {
            let primitives: [Primitive?] = serializables.map { _pack($0) }
            self[key] = Document(array: primitives)
        } else {
            self[key] = nil
        }
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
            throw Meow.Error.invalidValue(key: key, reason: "The amount of keys is not equal to the amount of values for this [\(K.self): \(V.self)]")
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
