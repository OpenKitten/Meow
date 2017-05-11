import MongoKitten

/// An Index attribute
public enum IndexAttribute {
    
    /// Equivalent to MongoKitten.IndexParameter.unique
    case unique
    
    /// Creates a MongoKitten IndexParameter
    var indexParameter: IndexParameter {
        switch self {
        case .unique:
            return .unique
        }
    }
}

extension Model {
    /// Creates an index on this entity
    ///
    /// - parameter keys: The keys: index and their order
    /// - parameter name: The index name
    /// - parameter attributes: The attributes to apply to this index
    public static func index(_ keys: [Key: SortOrder], named name: String, attributes: IndexAttribute...) throws {
        try self.index(keys, named: name, attributes: attributes)
    }
    
    /// Creates an index on this entity
    ///
    /// - parameter keys: The keys: index and their order
    /// - parameter name: The index name
    /// - parameter attributes: The attributes to apply to this index
    public static func index(_ keys: [Key: SortOrder], named name: String, attributes: [IndexAttribute]) throws {
        let sort = IndexParameter.sortedCompound(fields: keys.map { key, order in
            return (key.keyString, order)
        })
        
        let parameters: [IndexParameter] = [sort] + attributes.map { $0.indexParameter }
        
        try Self.collection.createIndexes([(name, parameters)])
    }
}
