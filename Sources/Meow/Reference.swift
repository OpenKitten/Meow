//
//  Reference.swift
//  Meow
//
//  Created by Robbert Brandsma on 19-06-17.
//

import Foundation

public protocol Referencing {
    var reference: ObjectId { get }
}

/// Reference to a Model
public struct Reference<M: Model> : Hashable, Referencing {
    /// The referenced id
    public let reference: ObjectId
    
    /// Compares two references to be referring to the same entity
    public static func ==(lhs: Reference<M>, rhs: Reference<M>) -> Bool {
        return lhs.reference == rhs.reference
    }
    
    /// Makes a reference hashable
    public var hashValue: Int {
        return reference.hashValue
    }
    
    /// Creates a reference from an entity
    public init(to entity: M) {
        reference = entity._id
    }
    
    /// Resolves a reference
    public func resolve() throws -> M {
        guard let referenced = try M.findOne("_id" == reference) else {
            throw Meow.Error.referenceError(id: reference, type: M.self)
        }
        
        return referenced
    }
}

extension Reference : Codable {
    public func encode(to encoder: Encoder) throws {
        try reference.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        reference = try ObjectId(from: decoder)
    }
}

infix operator ==>
public func ==><T>(lhs: Reference<T>, rhs: T) -> Bool {
    return lhs.reference == rhs._id
}

infix operator =>
public func =><T>(lhs: inout Reference<T>, rhs: T) {
    lhs = Reference(to: rhs)
}
