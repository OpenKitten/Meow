//
//  Indexes.swift
//  Meow
//
//  Created by Joannis Orlandos on 27/01/2017.
//
//

import MongoKitten

public enum Attributes {
    case unique
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
    public static func index(_ sort: Key, attributes: Attributes) throws {
        
    }
}
