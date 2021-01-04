//
//  Querying.swift
//  App
//
//  Created by Robbert Brandsma on 06/06/2018.
//

// Typesafe queries are currently only available if Vapor is available

import MongoKitten
import NIO

public protocol KeyPathQueryable {
    static func makeQueryPath<T>(for key: KeyPath<Self, T>) throws -> String
}

public protocol QueryableModel: KeyPathQueryable, Model {}
public protocol ConvertibleToQueryPath {
    func makeQueryPath() throws -> String
}

extension KeyPath: ConvertibleToQueryPath where Root: QueryableModel {

    public func makeQueryPath() throws -> String {
        return try Root.makeQueryPath(for: self)
    }

}

enum MeowQueryEncodingError: Error {
    case noResultingPrimitive
}

public struct ModelQuery<M: QueryableModel> {
    
    public var query: MongoKitten.Query
    
    public init(_ query: MongoKitten.Query = .init()) {
        self.query = query
    }
    
}

public extension AggregateCursor {
    func match<T>(_ query: ModelQuery<T>) -> AggregateCursor<Element> {
        return self.match(query.query)
    }
}

fileprivate struct TargetValueEncodingWrapper<V: Encodable>: Encodable {
    var value: V
}

fileprivate extension QueryableModel {
    static func encode<V: Encodable>(value: V) throws -> Primitive {
        let wrapper = TargetValueEncodingWrapper(value: value)
        let document = try Self.encoder.encode(wrapper)
        
        guard let result = document["value"] else {
            throw MeowQueryEncodingError.noResultingPrimitive
        }
        
        return result
    }
}

public func == <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V?) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue: Primitive?
    if let rhs = rhs {
        compareValue = try M.encode(value: rhs)
    } else {
        compareValue = nil
    }
    
    return ModelQuery(path == compareValue)
}

public func == <M: QueryableModel, T: Model>(lhs: KeyPath<M, Reference<T>>, rhs: T?) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue: Primitive?
    if let rhs = rhs {
    compareValue = try M.encode(value: rhs._id)
    } else {
    compareValue = nil
    }
    
    return ModelQuery(path == compareValue)
}

public func != <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V?) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue: Primitive?
    if let rhs = rhs {
        compareValue = try M.encode(value: rhs)
    } else {
        compareValue = nil
    }
    
    return ModelQuery(path != compareValue)
}

public func < <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue = try M.encode(value: rhs)
    
    return ModelQuery(path < compareValue)
}

public func > <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue = try M.encode(value: rhs)
    
    return ModelQuery(path > compareValue)
}

public func <= <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue = try M.encode(value: rhs)
    
    return ModelQuery(path <= compareValue)
}

public func >= <M: QueryableModel, V: Encodable>(lhs: KeyPath<M, V>, rhs: V) throws -> ModelQuery<M> {
    let path = try lhs.makeQueryPath()
    let compareValue = try M.encode(value: rhs)
    
    return ModelQuery(path >= compareValue)
}

public func || <M>(lhs: ModelQuery<M>, rhs: ModelQuery<M>) -> ModelQuery<M> {
    return ModelQuery(lhs.query || rhs.query)
}

public func && <M>(lhs: ModelQuery<M>, rhs: ModelQuery<M>) -> ModelQuery<M> {
    return ModelQuery(lhs.query && rhs.query)
}

public prefix func ! <M>(query: ModelQuery<M>) -> ModelQuery<M> {
    return ModelQuery(!query.query)
}

extension KeyPath where Root: QueryableModel, Value: Sequence, Value.Element: Encodable {
    public func contains(_ element: Value.Element) throws -> ModelQuery<Root> {
        let path = try self.makeQueryPath()
        let compareValue = try Root.encode(value: element)
        return ModelQuery(path == compareValue) // MongoDB allows matching array contains with "$eq"
    }
}

extension KeyPath where Root: QueryableModel, Value: Encodable {
    public func `in`(_ options: [Value]) throws -> ModelQuery<Root> {
        let path = try self.makeQueryPath()
        let compareValue = try options.map { try Root.encode(value: $0) }
        return ModelQuery(.in(field: path, in: compareValue))
    }
}

extension KeyPath where Root: QueryableModel, Value: Sequence, Value.Element: Encodable {
    public func `in`(_ options: [Value.Element]) throws -> ModelQuery<Root> {
        let path = try self.makeQueryPath()
        let compareValue = try options.map { try Root.encode(value: $0) }
        return ModelQuery(.in(field: path, in: compareValue))
    }
}
