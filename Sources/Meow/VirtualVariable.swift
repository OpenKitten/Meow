//
//  VirtualVariable.swift
//  Meow
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation
import MongoKitten

public protocol VirtualVariable {
    var name: String { get }
}

public protocol VirtualComparable : VirtualVariable {}

public func ==(lhs: VirtualVariable, rhs: ValueConvertible) -> Query {
    return lhs.name == rhs
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
    
    public func contains(_ other: ValueConvertible) -> Query {
        return [
            self.name: other
        ]
    }
}

// sourcery: compareType=Data
public struct VirtualData : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: donotequate
public struct VirtualReference<T : ConcreteModel, D : DeleteRule>: VirtualVariable {
    public var name: String
    public init(name: String) {
        self.name = name
    }
    
    public static func ==(lhs: VirtualReference<T,D>, rhs: T) -> MongoKitten.Query {
        return lhs.name == rhs.id
    }
}

// sourcery: donotequate
public struct VirtualReferenceArray<T : ConcreteModel, D : DeleteRule>: VirtualVariable {
    public var name: String
    public init(name: String) {
        self.name = name
    }
    
    public func contains(_ rhs: T) -> MongoKitten.Query {
        return self.name == rhs.id
    }
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

public protocol MeowNumber : ValueConvertible {}
extension Int : MeowNumber {}
extension Int32 : MeowNumber {}
extension Int64 : MeowNumber {}
extension Double : MeowNumber {}
