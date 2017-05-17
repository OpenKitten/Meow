import Foundation
import MongoKitten

/// A VirtualInstance is generated for every Serializable by Meow.
///
/// It serves as a generator and building block of the type safe query system.
///
/// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
public protocol VirtualModelInstance {
    /// Initialise a VirtualInstance using the given KeyPrefix
    ///
    /// - parameter keyPrefix: The keyPrefix is prefixed to all query keys as returned from the VirtualInstance, for the
    /// purpose of being able to embed structs.
    init(keyPrefix: String, isReference: Bool)
    
    var keyPrefix: String { get }
    var isReference: Bool { get }
}

extension VirtualModelInstance {
    public var referencedKeyPrefix: String {
        if isReference {
            return keyPrefix + "."
        } else {
            return keyPrefix
        }
    }
}

/// A virtual variable, as property on a VirtualModelInstance. Generates typesafe queries.
public protocol VirtualVariable {
    /// The name (key) of the variable.
    var name: String { get }
}

/// Generates a query which compares if a BSON primitive is equal to the property of a virutal variable
public func ==(lhs: VirtualVariable, rhs: Primitive?) -> Query {
    return lhs.name == rhs
}

/// A virtual document
public struct VirtualDocument : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    /// For generating queries that have effect on the given property
    public subscript(key: String) -> String {
        return name + "." + key
    }
}

// sourcery: compareType=String
public struct VirtualString : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    /// Generates a contains query using a regular expression. Returns results containing `other`.
    ///
    /// - parameter other: The string to search for
    /// - parameter options: Compare options
    public func contains(_ other: String, options: NSRegularExpression.Options = []) -> Query {
        return Query(aqt: .contains(key: self.name, val: other, options: options))
    }
    
    /// Generates a starts with query
    public func hasPrefix(_ other: String) -> Query {
        return Query(aqt: .startsWith(key: self.name, val: other))
    }
    
    /// Generates an ends with query
    public func hasSuffix(_ other: String) -> Query {
        return Query(aqt: .endsWith(key: self.name, val: other))
    }
}

// sourcery: compareType=ObjectId
public struct VirtualObjectId : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=MeowNumber
public struct VirtualNumber : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=Date
public struct VirtualDate : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=Bool
public struct VirtualBool : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: donotequate
public struct VirtualArray<V: VirtualVariable> : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    typealias VirtualSubtype = V.Type
    
    public func contains(_ other: Primitive) -> Query {
        return [
            self.name: other
        ]
    }
}

/// A queryable reference to `M`
// sourcery: donotequate
public struct VirtualReference<M : BaseModel> : VirtualVariable {
    /// :nodoc:
    public var name: String
    /// :nodoc:
    public init(name: String) { self.name = name }
    
    /// Matches if the subject refers to an object with `_id` `id`
    public func refers(to id: ObjectId) -> Query {
        return (self.name + "._id") == id
    }
    
    /// Matches if the subject refers to `instance`
    public func refers(to instance: M) -> Query {
        return self.refers(to: instance._id)
    }
    
    /// Matches if `lhs` refers to `rhs` 
    public static func ==(_ lhs: VirtualReference<M>, _ rhs: M?) -> Query {
        if let rhs = rhs {
            return lhs.refers(to: rhs)
        } else {
            return lhs == nil
        }
    }
}

// sourcery: donotequate
public struct VirtualEmbeddablesArray<V: Serializable> : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    public func contains(_ other: V) -> Query {
        return self.name == other.serialize()
    }
    
    public subscript(index: Int) -> String {
        return name + ".\(index)"
    }
}

// sourcery: compareType=Data
public struct VirtualData : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

public prefix func !(rhs: Query) -> Query {
    var query = Document()
    
    for (key, value) in rhs.makeDocument() {
        query[key] = [
            "$not": value
            ] as Document
    }
    
    return Query(query)
}

public protocol MeowNumber : Primitive {}
extension Int : MeowNumber {}
extension Int32 : MeowNumber {}
extension Double : MeowNumber {}
