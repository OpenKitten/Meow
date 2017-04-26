//
//  Serializable.swift
//  Meow
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation
import BSON

/// A protocol that is merely used to indicate an extension point
public protocol Serializable {
    init(restoring source: BSON.Primitive) throws
    
    func serialize() -> BSON.Primitive
}

