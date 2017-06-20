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
