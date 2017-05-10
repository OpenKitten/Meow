import MongoKitten

public enum Attribute {
    case unique
    
    var indexParameter: IndexParameter {
        switch self {
        case .unique:
            return .unique
        }
    }
}

public struct Fields : ExpressibleByDictionaryLiteral {
    var sort = Document()
    
    public init(dictionaryLiteral elements: (String, SortOrder)...) {
        for (key, order) in elements {
            sort[key] = order
        }
    }
}

extension Model {
    public static func index(_ keys: [Key: SortOrder], named name: String, attributes: Attribute...) throws {
        try self.index(keys, named: name, attributes: attributes)
    }
    
    public static func index(_ keys: [Key: SortOrder], named name: String, attributes: [Attribute]) throws {
        let sort = IndexParameter.sortedCompound(fields: keys.map { key, order in
            return (key.keyString, order)
        })
        
        let parameters: [IndexParameter] = [sort] + attributes.map { $0.indexParameter }
        
        try Self.collection.createIndexes([(name, parameters)])
    }
}
