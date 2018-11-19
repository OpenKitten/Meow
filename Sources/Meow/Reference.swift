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
    public func resolve(in context: Context, where query: Query = Query()) -> EventLoopFuture<M> {
        return resolveIfPresent(in: context, where: query).thenThrowing { referenced in
            guard let referenced = referenced else {
                throw MeowError.referenceError(id: self.reference, type: M.self)
            }
            
            return referenced
        }
    }
    
    /// Resolves a reference, returning `nil` if the referenced object cannot be found
    public func resolveIfPresent(in context: Context, where query: Query = Query()) -> EventLoopFuture<M?> {
        return context.findOne(M.self, where: "_id" == reference && query)
    }
    
    /// Deletes the target of the reference (making it invalid)
    public func deleteTarget(in context: Context) -> EventLoopFuture<Void> {
        return context.deleteOne(M.self, where: "_id" == reference).map { _ in }
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
    associatedtype IfPresentResult
    
    func resolve(in context: Context, where query: Query) -> EventLoopFuture<Result>
    func resolveIfPresent(in context: Context, where query: Query) -> EventLoopFuture<IfPresentResult>
}

public extension Resolvable where Result: QueryableModel {
    public func resolve(in context: Context, where query: ModelQuery<Result>) -> EventLoopFuture<Result> {
        return self.resolve(in: context, where: query.query)
    }
    
    public func resolveIfPresent(in context: Context, where query: ModelQuery<Result>) -> EventLoopFuture<IfPresentResult> {
        return self.resolveIfPresent(in: context, where: query.query)
    }
}

public extension Resolvable where Result: Sequence, Result.Element: QueryableModel {
    public func resolve(in context: Context, where query: ModelQuery<Result.Element>) -> EventLoopFuture<Result> {
        return self.resolve(in: context, where: query.query)
    }
    
    public func resolveIfPresent(in context: Context, where query: ModelQuery<Result.Element>) -> EventLoopFuture<IfPresentResult> {
        return self.resolveIfPresent(in: context, where: query.query)
    }
}

extension Set: Resolvable where Element: Resolvable {}
extension Array: Resolvable where Element: Resolvable {}
extension Sequence where Element: Resolvable {
    /// Resolves the contained references
    ///
    /// - parameter context: The context to use for resolving the references
    /// - returns: An EventLoopFuture that completes with an array of
    public func resolve(in context: Context, where query: Query = Query()) -> EventLoopFuture<[Element.Result]> {
        let futures = self.map { $0.resolve(in: context, where: query) }
        return EventLoopFuture.reduce(into: [], futures, eventLoop: context.eventLoop) { array, resolved in
            array.append(resolved)
        }
    }
    
    public func resolveIfPresent(in context: Context, where query: Query = Query()) -> EventLoopFuture<[Element.IfPresentResult]> {
        let futures = self.map { $0.resolveIfPresent(in: context, where: query) }
        return EventLoopFuture.reduce(into: [], futures, eventLoop: context.eventLoop) { array, resolved in
            array.append(resolved)
        }
    }
}

extension Dictionary: Resolvable where Value: Resolvable {
    public typealias Result = [Key: Value.Result]
    public typealias IfPresentResult = [Key: Value.IfPresentResult]
    
    public func resolve(in context: Context, where query: Query = Query()) -> EventLoopFuture<[Key: Value.Result]> {
        let futures = self.map { $0.value.resolve(in: context, where: query).and(result: $0.key) }
        return EventLoopFuture.reduce(into: [:], futures, eventLoop: context.eventLoop) { dictionary, pair in
            let (value, key) = pair
            
            dictionary[key] = value
        }
    }
    
    public func resolveIfPresent(in context: Context, where query: Query = Query()) -> EventLoopFuture<[Key: Value.IfPresentResult]> {
        let futures = self.map { $0.value.resolveIfPresent(in: context, where: query).and(result: $0.key) }
        return EventLoopFuture.reduce(into: [:], futures, eventLoop: context.eventLoop) { dictionary, pair in
            let (value, key) = pair
            
            dictionary[key] = value
        }
    }
}

extension Optional: Resolvable where Wrapped: Resolvable {
    public typealias Result = Wrapped.Result?
    public typealias IfPresentResult = Wrapped.IfPresentResult?
    
    public func resolve(in context: Context, where query: Query) -> EventLoopFuture<Wrapped.Result?> {
        switch self {
        case .none: return context.eventLoop.newSucceededFuture(result: nil)
        case .some(let value): return value.resolve(in: context, where: query).map { $0 }
        }
    }
    
    public func resolveIfPresent(in context: Context, where query: Query) -> EventLoopFuture<Wrapped.IfPresentResult?> {
        switch self {
        case .none: return context.eventLoop.newSucceededFuture(result: nil)
        case .some(let value): return value.resolveIfPresent(in: context, where: query).map { $0 }
        }
    }
}
