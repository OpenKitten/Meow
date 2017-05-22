import MongoKitten

extension Model {
    /// Finds all relationships for a given Model. Related entities must be of the same type.
    ///
    /// - parameter query: The query to which all initial entities must match. Entities that do not match may still be related to a matching entity
    /// - parameter foreignKey: The key in the foreign document to look up in the localKey array/variable
    /// - parameter localKey: The key in the currently investigated entity/relationship to follow to another foreignKey
    /// - parameter maxDepth: The  maximum amount of lookups to perform from localKey to foreignKey
    /// - parameter restrictions: The restrictions that related entities *must* conform to. This query only supports keys, operators and literals. No complex operations are allowed such as projection operators.
    ///
    /// - returns: A cursor to all entities and their relations
    public static func findRelations(forEntitiesMatching query: Query? = nil, whereForeignKey foreignKey: Self.Key, existsAt localKey: Self.Key, until maxDepth: Int? = nil, restrictions: Query? = nil) throws -> Cursor<Relation<Self>> {
        var pipeline = AggregationPipeline()
        let localKeyString = localKey.keyString
        
        if let query = query {
            (pipeline, _) = try Self.makeQueryPipeline(for: query)
        }
        
        // TODO: Expose
        let startValue = "$" + localKeyString
        
        pipeline.append(AggregationPipeline.Stage([
            "$graphLookup": [
                "from": collection.name,
                "startWith": startValue,
                "connectFromField": localKeyString,
                "connectToField": foreignKey.keyString,
                "as": "meowHierarchy",
                "maxDepth": maxDepth,
                "depthField": "_meowDepth",
                "restrictSearchWithMatch": restrictions
            ] as Document
        ]))
        
        return try collection.aggregate(pipeline).flatMap { document in
            do {
                var document = document
                
                guard let traversedDocuments = Document(document.removeValue(forKey: "meowHierarchy")) else {
                    return nil
                }
                
                let traversedEntities: [(Self, Int)] = try traversedDocuments.arrayValue.flatMap(Document.init).map { document in
                    let depth: Int = try document.unpack("_meowDepth")
                    
                    return (try Self.instantiateIfNeeded(document), depth)
                }
                
                return Relation(try Self.instantiateIfNeeded(document), relatedTo: traversedEntities)
            } catch {
                Meow.log("Initializing from document failed: \(error)")
                assertionFailure()
                return nil
            }
        }
    }
}

/// A relationship holder. Keeps track of the entity that's being investigated as well as it's relations and the distance to the relations
public struct Relation<M: BaseModel & Hashable> {
    /// The entity that's being investigated
    public let entity: M
    
    /// The related other entities and their distance
    public let relations: [(relation: M, depth: Int)]
    
    /// Orders the relations in an array from close to far away
    public func orderRelationsClosest() -> [M] {
        return relations.sorted { lhs, rhs in
            return lhs.depth < rhs.depth
        }.map { $0.relation }
    }
    
    /// Orders the relations in an array from far away to close
    public func orderRelationsFurthest() -> [M] {
        return relations.sorted { lhs, rhs in
            return lhs.depth > rhs.depth
            }.map { $0.relation }
    }
    
    /// Creates a new Relationship from preprocessed information
    fileprivate init(_ entity: M, relatedTo traversedEntities: [(relation: M, depth: Int)]) {
        self.entity = entity
        self.relations = traversedEntities
    }
}
