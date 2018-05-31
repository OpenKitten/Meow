import Foundation
import NIO

/// Reference to a Model
public struct Reference<M: Model> : Hashable {
    /// The referenced id
    public let reference: M.Identifier
    
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
    
    
    /// Resolves a reference
    public func resolve(in context: Context) throws -> EventLoopFuture<M> {
        return resolveIfPresent(in: context).thenThrowing { referenced in
            guard let referenced = referenced else {
                throw MeowError.referenceError(id: self.reference, type: M.self)
            }
            
            return referenced
        }
    }
    
    /// Resolves a reference, returning `nil` if the referenced object cannot be found
    public func resolveIfPresent(in context: Context) -> EventLoopFuture<M?> {
        return context.findOne(M.self, query: "_id" == reference)
    }
}

extension Reference : Codable {
    public func encode(to encoder: Encoder) throws {
        try reference.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        reference = try M.Identifier(from: decoder)
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
