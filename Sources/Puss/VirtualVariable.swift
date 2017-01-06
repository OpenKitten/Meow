//
//  VirtualVariable.swift
//  Puss
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation
import MongoKitten

public protocol VirtualVariable {
    var name: String { get }
    init(name: String)
}

public protocol VirtualEquatable : VirtualVariable {}

public func ==(lhs: VirtualEquatable, rhs: ValueConvertible) -> Query {
    return lhs.name == rhs
}

public struct VirtualString : VirtualEquatable {
    public var name: String
    public init(name: String) { self.name = name }
    
    public func contains(_ value: String, options: NSRegularExpression.Options = []) -> Query {
        return Query(aqt: .contains(key: self.name, val: value, options: options))
    }
}

