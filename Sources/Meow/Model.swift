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
    
    // MARK: - Serialization
    
    /// The `_id` of the model. *This property MUST be encoded with `_id` as key*
    var _id: ObjectId { get set }
    
    /// The collection instances of the model live in. A default implementation is provided.
    static var collection: MongoKitten.Collection { get }
    
    /// The BSON decoder used for decoding instances of this model. A default implementation is provided.
    static var decoder: BSONDecoder { get }
    
    /// The BSON encoder used for encoding instances of this model. A default implementation is provided.
    static var encoder: BSONEncoder { get }
    
    // MARK: - Hooks
    
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    func willSave() throws
    
    /// Will be called when the Model has been saved.
    func didSave() throws
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    func willDelete() throws
    
    /// Will be called when the Model is deleted. At this point, it is no longer in the database and saves will no longer work because the ObjectId is invalidated.
    func didDelete() throws
    
}

public protocol Model : _Model {
    
}

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
    
    func willSave() throws {}
    func didSave() throws {}
    func willDelete() throws {}
    func didDelete() throws {}
}

// MARK: - Saving and updating
public extension _Model {
    public func save() throws {
        Meow.pool.pool(self)
        
        try self.willSave()
        try Meow.middleware.forEach { try $0.willSave(instance: self) }
        
        let encoder = Self.encoder
        let document = try encoder.encode(self)
        
        try Self.collection.update("_id" == self._id,
                                   to: document,
                                   upserting: true)
        
        try self.didSave()
        try Meow.middleware.forEach { try $0.didSave(instance: self) }
    }
    
    /// Removes this object from the database
    ///
    /// Before deleting, `willDelete()` is called. `willDelete()` can throw to prevent the deletion.
    /// When the deletion is complete, `didDelete()` is called.
    public func delete() throws {
        try self.willDelete()
        try Meow.middleware.forEach { try $0.willDelete(instance: self) }
        Meow.pool.invalidate(self._id)
        try Self.collection.remove("_id" == self._id)
        try self.didDelete()
        try Meow.middleware.forEach { try $0.didDelete(instance: self) }
    }
}

// MARK: - Querying
public extension _Model {
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
                print("Could not initialize \(Self.self) from document\n_id: \(ObjectId(document["_id"])?.hexString ?? document["_id"] ?? "unknown")\nError: \(error)\n")
                print("Place a breakpoint in Meow at \(#file):\(#line) to catch this error in the debugger")
                return nil
            }
            })
    }
    
    /// Returns the first object matching the query
    public static func findOne(_ query: Query? = nil, sortedBy sort: Sort? = nil) throws -> Self? {
        // TODO: Don't reuse find here because that one does not have proper error reporting
        return try Self.find(query, sortedBy: sort, limitedTo: 1, withBatchSize: 1).makeIterator().next()
    }
    
    /// Counts the amount of objects matching the query
    public static func count(_ filter: Query? = nil, limitedTo limit: Int? = nil, skipping skip: Int? = nil) throws -> Int {
        let prepared = try Self.prepareQuery(filter, skipping: skip, limitedTo: limit)
        
        switch prepared {
        case .aggregate(var pipeline):
            pipeline.append(.count(insertedAtKey: "_meowCount"))
            guard let count = Int(try Self.collection.aggregate(pipeline, options: [.cursorOptions(["batchSize": 1])]).next()?["_meowCount"]) else {
                throw MongoError.internalInconsistency
            }
            
            return count
        case .find(let query, _, let skip, let limit, _):
            print(query!.aqt)
            return try collection.count(query, limitedTo: limit, skipping: skip)
        }
    }
}

// MARK: - Query Preperation and Execution
internal extension _Model {
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
