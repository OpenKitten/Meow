//
//  QueryBuilder.swift
//  Meow
//
//  Created by Robbert Brandsma on 20/06/2017.
//

import Foundation
import MongoKitten

public func ==(lhs: String, rhs: Referencing) -> Query {
    return lhs == rhs.reference
}

// MARK: - Typesafe Queries

public struct TypesafeQuery<Root> {
    var query: Query
}

public enum QueryBuilderError : Error {
    case unknownKeyPath
    case unserializable
}

fileprivate struct QueryEncodingHelper<V : Encodable> : Encodable {
    var value: V
}

fileprivate func prepare<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> (key: String, value: Primitive?) where Value : Encodable, Root : KeyPathListable & Model {
    let path = try lhs.makeIdentifier()
    
    let helper = QueryEncodingHelper(value: rhs)
    let document = try Root.encoder.encode(helper)
    let primitive = document["value"]
    
    return (path, primitive)
}

public func &&<Root>(lhs: TypesafeQuery<Root>, rhs: TypesafeQuery<Root>) -> TypesafeQuery<Root> {
    return TypesafeQuery(query: lhs.query && rhs.query)
}

public func ||<Root>(lhs: TypesafeQuery<Root>, rhs: TypesafeQuery<Root>) -> TypesafeQuery<Root> {
    return TypesafeQuery(query: lhs.query || rhs.query)
}

extension KeyPath where Root : Model & KeyPathListable, Value : Sequence & Codable, Value.Element : Codable {
    public func contains(_ element: Value.Element) throws -> TypesafeQuery<Root> {
        let path = try self.makeIdentifier()
        
        let helper = QueryEncodingHelper(value: element)
        let document = try Root.encoder.encode(helper)
        guard let primitive = document["value"] else {
            throw QueryBuilderError.unserializable
        }
        
        return TypesafeQuery(query: path == primitive)
    }
}

public func ==<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable, Root : KeyPathListable & Model {
    let (key, value) = try prepare(lhs: lhs, rhs: rhs)
    
    return TypesafeQuery(query: key == value)
}

public func !=<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable, Root : KeyPathListable & Model {
    let (key, value) = try prepare(lhs: lhs, rhs: rhs)
    
    return TypesafeQuery(query: key != value)
}

public func ><Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable & Comparable, Root : KeyPathListable & Model {
    let (key, maybeValue) = try prepare(lhs: lhs, rhs: rhs)
    guard let value = maybeValue else { throw QueryBuilderError.unserializable }
    
    return TypesafeQuery(query: key > value)
}

public func <<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable & Comparable, Root : KeyPathListable & Model {
    let (key, maybeValue) = try prepare(lhs: lhs, rhs: rhs)
    guard let value = maybeValue else { throw QueryBuilderError.unserializable }
    
    return TypesafeQuery(query: key < value)
}

public func >=<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable & Comparable, Root : KeyPathListable & Model {
    let (key, maybeValue) = try prepare(lhs: lhs, rhs: rhs)
    guard let value = maybeValue else { throw QueryBuilderError.unserializable }
    
    return TypesafeQuery(query: key >= value)
}

public func <=<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Encodable & Comparable, Root : KeyPathListable & Model {
    let (key, maybeValue) = try prepare(lhs: lhs, rhs: rhs)
    guard let value = maybeValue else { throw QueryBuilderError.unserializable }
    
    return TypesafeQuery(query: key <= value)
}

public extension _Model {
    public static func find(_ query: TypesafeQuery<Self>, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = Meow.defaultBatchSize) throws -> AnySequence<Self> {
        return try Self.find(query.query, sortedBy: sort, skipping: skip, limitedTo: limit, withBatchSize: batchSize)
    }
    
    public static func findOne(_ query: TypesafeQuery<Self>, sortedBy sort: Sort? = nil) throws -> Self? {
        return try Self.findOne(query.query, sortedBy: sort)
    }
}

// MARK: - Typesafe Sort

// TODO: Think of ideas?
// try Foo.find(sortedBy: ascending(\.foo, \.bar))
// Ascending: try Foo.find(sortedBy: \.foo > \.bar), Descending: try Foo.find(sortedBy: !(\.foo > \.bar))
