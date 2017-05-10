import Foundation
import MongoKitten

#if os(Linux)
    public typealias NSRegularExpression = RegularExpression
#endif

public protocol VirtualVariable {
    var name: String { get }
}

public protocol VirtualComparable : VirtualVariable {}

public func ==(lhs: VirtualVariable, rhs: Primitive?) -> Query {
    return lhs.name == rhs
}

public struct VirtualDocument : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    public subscript(key: String) -> String {
        return name + "." + key
    }
}

// sourcery: compareType=String
public struct VirtualString : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    public func contains(_ other: String, options: NSRegularExpression.Options = []) -> Query {
        return Query(aqt: .contains(key: self.name, val: other, options: options))
    }
    
    public func hasPrefix(_ other: String) -> Query {
        return Query(aqt: .startsWith(key: self.name, val: other))
    }
    
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
public struct VirtualNumber : VirtualComparable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=Date
public struct VirtualDate : VirtualComparable {
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

// sourcery: donotequate
public struct VirtualEmbeddablesArray<V: Serializable> : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    typealias VirtualSubtype = V.Type
    
    public func contains(_ other: V) -> Query {
        return [
            self.name: other.serialize()
        ]
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
