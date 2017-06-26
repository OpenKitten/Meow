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

public struct TypesafeQuery<Root> {
    var query: Query
}

public enum QueryBuilderError : Error {
    case unknownKeyPath
}

public func ==<Root, Value>(lhs: KeyPath<Root, Value>, rhs: Value) throws -> TypesafeQuery<Root> where Value : Primitive, Root : KeyPathListable {
    // Find the key path
    guard let path = (Root.allKeyPaths.first { $0.value == lhs }) else {
        throw QueryBuilderError.unknownKeyPath
    }
    
    return TypesafeQuery(query: path.key == rhs)
}

public extension _Model {
    public static func find(_ query: TypesafeQuery<Self>) throws -> AnySequence<Self> {
        return try Self.find(query.query)
    }
}
