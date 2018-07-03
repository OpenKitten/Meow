import Foundation
import NIO

/// Reference to a Model
public struct Reference<M: Model>: Hashable, Resolvable {
    /// The referenced id
    public let reference: M.Identifier
    
    public typealias Result = M
    
    /// Compares two references to be referring to the same entity
    public static func == (lhs: Reference<M>, rhs: Reference<M>) -> Bool {
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
    
    /// Creates an unchecked reference to an entity
    public init(unsafeTo target: M.Identifier) {
        reference = target
    }
    
    /// Resolves a reference
    public func resolve(in context: Context) -> EventLoopFuture<M> {
        return resolveIfPresent(in: context).thenThrowing { referenced in
            guard let referenced = referenced else {
                throw MeowError.referenceError(id: self.reference, type: M.self)
            }
            
            return referenced
        }
    }
    
    /// Resolves a reference, returning `nil` if the referenced object cannot be found
    public func resolveIfPresent(in context: Context) -> EventLoopFuture<M?> {
        return context.findOne(M.self, where: "_id" == reference)
    }
}

public postfix func * <M>(instance: M) -> Reference<M> {
    return Reference(to: instance)
}

postfix operator *

extension Reference: Codable {
    public func encode(to encoder: Encoder) throws {
        try reference.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        reference = try M.Identifier(from: decoder)
    }
}

public protocol Resolvable {
    associatedtype Result
    
    func resolve(in context: Context) -> EventLoopFuture<Result>
}

extension Set: Resolvable where Element: Resolvable {}
extension Array: Resolvable where Element: Resolvable {}
extension Sequence where Element: Resolvable {
    public typealias Result = [Element.Result]
    
    /// Resolves the contained references
    ///
    /// - parameter context: The context to use for resolving the references
    /// - returns: An EventLoopFuture that completes with an array of
    public func resolve(in context: Context) -> EventLoopFuture<[Element.Result]> {
        let futures = self.map { $0.resolve(in: context) }
        return EventLoopFuture.reduce(into: [], futures, eventLoop: context.eventLoop) { array, resolved in
            array.append(resolved)
        }
    }
}

extension Dictionary: Resolvable where Value: Resolvable {
    public typealias Result = [Key: Value.Result]
    
    public func resolve(in context: Context) -> EventLoopFuture<[Key: Value.Result]> {
        let futures = self.map { $0.value.resolve(in: context).and(result: $0.key) }
        return EventLoopFuture.reduce(into: [:], futures, eventLoop: context.eventLoop) { dictionary, pair in
            let (value, key) = pair
            
            dictionary[key] = value
        }
    }
}
