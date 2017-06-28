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

public protocol _UnassociatedReferenceProtocol : Referencing {}

public protocol _ReferenceProtocol : Referencing {
    associatedtype M : Model
    func resolve() throws -> M
}

/// Reference to a Model
public struct Reference<M: Model> : Hashable, _ReferenceProtocol, _UnassociatedReferenceProtocol {
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
    
    /// Creates a reference to an entity
    public init(to entity: M) {
        reference = entity._id
    }
    
    /// Creates a reference to an entity with given identifier
    /// The reference is checked and additional constraints for the check can be given
    public init(to id: ObjectId, constraints: Query = Query()) throws {
        guard try M.count("_id" == id && constraints) == 1 else {
            throw Meow.Error.referenceError(id: id, type: M.self)
        }
        
        self.reference = id
    }
    
    /// Resolves a reference
    public func resolve() throws -> M {
        guard let referenced = try resolveIfPresent() else {
            throw Meow.Error.referenceError(id: reference, type: M.self)
        }
        
        return referenced
    }
    
    /// Resolves a reference, returning `nil` if the referenced object cannot be found
    public func resolveIfPresent() throws -> M? {
        return try M.findOne("_id" == reference)
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
