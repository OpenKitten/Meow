import MongoKitten

extension Model {
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

public struct Relation<M: BaseModel & Hashable> {
    public let entity: M
    public let relations: [(relation: M, depth: Int)]
    
    public func orderRelationsClosest() -> [M] {
        return relations.sorted { lhs, rhs in
            return lhs.depth < rhs.depth
        }.map { $0.relation }
    }
    
    public func orderRelationsFurthest() -> [M] {
        return relations.sorted { lhs, rhs in
            return lhs.depth > rhs.depth
            }.map { $0.relation }
    }
    
    fileprivate init(_ entity: M, relatedTo traversedEntities: [(relation: M, depth: Int)]) {
        self.entity = entity
        self.relations = traversedEntities
    }
}
