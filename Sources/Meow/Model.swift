//
//  Model.swift
//  Meow
//
//  Created by Robbert Brandsma on 19-06-17.
//

import Foundation
import MongoKitten

/// Private base protocol for `Model` without Self or associated type requirements
public protocol _Model : class, Codable {
    
    /// The `_id` of the model. *This property MUST be encoded with `_id` as key*
    var _id: ObjectId { get set }
    
    /// The collection instances of the model live in. A default implementation is provided.
    static var collection: MongoKitten.Collection { get }
    
    /// The BSON decoder used for decoding instances of this model. A default implementation is provided.
    static var decoder: BSONDecoder { get }
    
    /// The BSON encoder used for encoding instances of this model. A default implementation is provided.
    static var encoder: BSONEncoder { get }
}

public protocol Model : _Model {}

// MARK: - Default implementations
public extension Model {
    static var collection: MongoKitten.Collection {
        let typeName = String(describing: Self.self)
        return Meow.database[typeName]
    }
    
    static var decoder: BSONDecoder {
        return BSONDecoder()
    }
    
    static var encoder: BSONEncoder {
        return BSONEncoder()
    }
}

// MARK: - Saving
public extension Model {
    public func save() throws {
        Meow.pool.pool(self)
        
        let encoder = Self.encoder
        let document = try encoder.encode(self)
        
        try Self.collection.update("_id" == self._id,
                                   to: document,
                                   upserting: true
        )
    }
}

// MARK: - Querying
public extension Model {
    /// Returns all objects matching the query
    ///
    /// - parameter query: The query to compare the database entities with
    /// - parameter sort: The order to sort the entities by
    public static func find(_ query: Query? = nil, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100, allowOptimizing: Bool = true) throws -> AnySequence<Self> {
        
        // Query optimisations
        if allowOptimizing && sort == nil && skip == nil, let aqt = query?.aqt {
            if case .valEquals("_id", let val) = aqt {
                // Meow only supports ObjectId as _id, so if it isn't an ObjectId we can safely return an empty result
                guard let val = val as? ObjectId else {
                    return AnySequence([])
                }
                
                // we have this id in memory, so return that
                if let instance: Self = Meow.pool.getPooledInstance(withIdentifier: val) {
                    return AnySequence([instance])
                }
            }
        }
        
        let prepared = try Self.prepareQuery(query, sortedBy: sort, skipping: skip, limitedTo: limit)
        let result = try Self.runPreparedQuery(prepared, batchSize: batchSize)
        
        return AnySequence(try result.flatMap { document in
            do {
                return try Meow.pool.instantiateIfNeeded(type: Self.self, document: document)
            } catch {
                Meow.log("Initializing from document failed: \(error)")
                assertionFailure("Could not initialize \(Self.self) from document\n_id: \(ObjectId(document["_id"])?.hexString ?? document["_id"] ?? "unknown")\nError: \(error)\n")
                return nil
            }
            })
    }
    
    /// Returns the first object matching the query
    public static func findOne(_ query: Query? = nil, sortedBy sort: Sort? = nil) throws -> Self? {
        // TODO: Don't reuse find here because that one does not have proper error reporting
        return try Self.find(query, sortedBy: sort, limitedTo: 1, withBatchSize: 1).makeIterator().next()
    }
}

// MARK: - Query Preperation and Execution
internal extension Model {
    /// - parameter query; A PreparedQuery, either a find operation or an aggregationPipeline.
    /// - parameter batchSize: The amount of documents to fetch per group/batch of entities
    /// - throws: Unable to run the query on the server due to connection issues, permission issues or an incompatible MongoDB server version for this operation
    /// - returns: A cursor containing the Document form of this BaseModel entity
    static func runPreparedQuery(_ query: PreparedQuery, batchSize: Int = 100) throws -> Cursor<Document> {
        switch query {
        case .aggregate(let pipeline):
            return try Self.collection.aggregate(pipeline, options: [.cursorOptions(["batchSize": batchSize])])
        case .find(let query, let sort, let skip, let limit, let project):
            return try Self.collection.find(query, sortedBy: sort, projecting: project, skipping: skip, limitedTo: limit, withBatchSize: batchSize).cursor
        }
    }
    
    /// Prepares a query given a set of parameters. This query can be either a find operation or aggregation pipeline
    ///
    /// - parameter query: The query that is being executed which allows references to be queries, too
    /// - parameter sort: The key to sort results by
    /// - parameter projection: The projection to apply to this operation. If the projection is set, not all fields will be returned
    /// - parameter skip: The amount of resulting entities to skip before starting to return them
    /// - parameter limit: The maximum amount of entities to return, excluding those that were skipped
    /// - returns: A prepared query that is either a `find` or `aggregation` operation
    static func prepareQuery(_ query: Query? = nil, sortedBy sort: Sort? = nil, projecting projection: Projection? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil) throws -> PreparedQuery {
        var pipeline = AggregationPipeline()
        let requirePipeline = false
        let query = query?.makeDocument()
        
        // TODO: Optimize the query here.
        
        if !requirePipeline {
            if let query = query {
                return .find(query: Query(query), sort: sort, skip: skip, limit: limit, project: projection)
            } else {
                return .find(query: nil, sort: sort, skip: skip, limit: limit, project: projection)
            }
        }
        
        if let sort = sort {
            pipeline.append(.sort(sort))
        }
        
        if let skip = skip {
            pipeline.append(.skip(skip))
        }
        
        if let limit = limit {
            pipeline.append(.limit(limit))
        }
        
        return .aggregate(pipeline)
    }
}

/// A read query that can be executed
public enum PreparedQuery {
    /// Finds entities using a single-stage normal `find` operation
    case find(query: Query?, sort: Sort?, skip: Int?, limit: Int?, project: Projection?)
    
    /// A complex aggregation pipeline with joins/$lookup stages.
    case aggregate(AggregationPipeline)
}

// MARK: - Autocompleted Queries
// TODO: Implement these when SR-5215 is fixed so we can make it a requirement in the Model protocol
public extension Model {
//    public func find(_ query: ModelQuery) {
//        
//    }
}

public struct ModelQuery<K : CodingKey> {
    var query: MongoKitten.Query
}

public func ==<K>(lhs: K, rhs: BSON.Primitive?) -> ModelQuery<K> {
    return ModelQuery<K>(query: lhs.stringValue == rhs)
}

// MARK: - Internal Helpers
extension _Model {
    internal static func instantiateIfNeeded(document: Document) throws -> Self {
        return try Meow.pool.instantiateIfNeeded(type: Self.self, document: document)
    }
}
