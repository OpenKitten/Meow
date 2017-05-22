import MongoKitten

/// A holder for static and instance helpers on BaseModel
///
/// Used to prevent bloating the model's type with internal/plugin functionality
public class BaseModelHelper<M: BaseModel> {
    /// Stores an instance of an entity to hold helper functions and apply them for a specific model
    public let entity: M
    
    /// Initializes a helper for a BaseModel instance so that helper functions can be called on the BaseModelHelper instance (wrapper)
    public init(_ entity: M) {
        self.entity = entity
    }
    
    /// - parameter query; A PreparedQuery, either a find operation or an aggregationPipeline.
    /// - parameter batchSize: The amount of documents to fetch per group/batch of entities
    /// - throws: Unable to run the query on the server due to connection issues, permission issues or an incompatible MongoDB server version for this operation
    /// - returns: A cursor containing the Document form of this BaseModel entity
    public static func runPreparedQuery(_ query: PreparedQuery, batchSize: Int = 100) throws -> Cursor<Document> {
        switch query {
        case .aggregate(let pipeline):
            return try M.collection.aggregate(pipeline, options: [.cursorOptions(["batchSize": batchSize])])
        case .find(let query, let sort, let skip, let limit, let project):
            return try M.collection.find(query, sortedBy: sort, projecting: project, skipping: skip, limitedTo: limit, withBatchSize: batchSize).cursor
        }
    }
    
    /// Creates a pipeline according to query specification. If necessary, performs $lookup or left-joins on other collections and queries those entities, too.
    ///
    /// - parameter query: The query to generate an aggregation pipeline for
    /// - throws: When recursively referring to the same model, potentially creating an infinite join loop
    /// - returns: A tuple containing the pipeline and a boolean. The boolean will be true if left-joins have been applied and the pipeline is thus requires for properly executing this query.
    public static func makeQueryPipeline(for query: Query) throws -> (pipeline: AggregationPipeline, required: Bool) {
        var query = query.makeDocument()
        var pipeline = AggregationPipeline()
        var requirePipeline = false
        var references = [(String, BaseModel.Type)]()
        let referenceKeys = try M.recursiveKeysWithReferences(chainedFrom: [])
        
        let referencedKeys = query.flattened().keys
        var firstQuery = Document()
        
        var stages: [AggregationPipeline.Stage] = []
        
        func parseQuery(forKey prefix: [SubscriptExpressionType]) {
            for (referenceKey, referenceType) in referenceKeys {
                var prefixTotal = ""
                var matches = false
                
                prefixCheck: for part in prefix {
                    switch part.subscriptExpression {
                    case .kittenBytes(let bytes):
                        if let s = String(bytes: bytes.bytes, encoding: .utf8) {
                            prefixTotal += s
                        }
                        
                        if prefixTotal.hasPrefix(referenceKey + ".") {
                            matches = true
                            break prefixCheck
                        }
                    default:
                        continue
                    }
                }
                
                if matches {
                    requirePipeline = true
                    references.append((referenceKey, referenceType))
                    stages.append(.lookup(from: referenceType.collection, localField: referenceKey, foreignField: "_id", as: referenceKey))
                } else {
                    firstQuery[prefix] = query[prefix]
                    query[prefix] = nil
                }
            }
        }
        
        for key in query.keys {
            parseQuery(forKey: [key])
        }
        
        if firstQuery.count > 0 {
            pipeline.append(.match(firstQuery))
        }
        
        for stage in stages {
            pipeline.append(stage)
        }
        
        if query.count > 0 {
            pipeline.append(.match(query))
        }
        
        return (pipeline, requirePipeline)
    }
    
    /// Prepares a query given a set of parameters. This query can be either a find operation or aggregation pipeline
    ///
    /// - parameter query: The query that is being executed which allows references to be queries, too
    /// - parameter sort: The key to sort results by
    /// - parameter projection: The projection to apply to this operation. If the projection is set, not all fields will be returned
    /// - parameter skip: The amount of resulting entities to skip before starting to return them
    /// - parameter limit: The maximum amount of entities to return, excluding those that were skipped
    /// - throws: When recursively referencing the same collection, thus creating an infinite loop
    /// - returns: A prepared query that is either a `find` or `aggregation` operation
    public static func prepareQuery(_ query: Query? = nil, sortedBy sort: Sort? = nil, projecting projection: Projection? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil) throws -> PreparedQuery {
        var pipeline = AggregationPipeline()
        var requirePipeline = false
        
        if let query = query {
            (pipeline, requirePipeline) = try makeQueryPipeline(for: query)
        }
        
        if !requirePipeline {
            return .find(query: query, sort: sort, skip: skip, limit: limit, project: projection)
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

/// A holder for static and instance helpers on Model
///
/// Used to prevent bloating the model's type with internal/plugin functionality
public class Helper<M: Model> : BaseModelHelper<M> {
    
}

/// A read query that can be executed
///
/// TODO: Support `count`?
public enum PreparedQuery {
    /// Finds entities using a single-stage normal `find` operation
    case find(query: Query?, sort: Sort?, skip: Int?, limit: Int?, project: Projection?)
    
    /// A complex aggregation pipeline with joins/$lookup stages.
    case aggregate(AggregationPipeline)
}
