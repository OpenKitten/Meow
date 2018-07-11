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

extension KeyPath where Root: QueryableModel {

    func makeQueryPath() throws -> String {
        return try Root.makeQueryPath(for: self)
    }

}

enum MeowQueryEncodingError: Error {
    case noResultingPrimitive
}

public struct ModelQuery<M: QueryableModel> {
    
    public var query: MongoKitten.Query
    
    public init(_ query: MongoKitten.Query) {
        self.query = query
    }
    
}

public extension AggregateCursor {
    public func match<T>(_ query: ModelQuery<T>) -> AggregateCursor<Element> {
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
