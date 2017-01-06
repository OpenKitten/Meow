//
//  Embeddable.swift
//  Meow
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation

public protocol Serializable {}

public protocol ConcreteSerializable {
    init(fromDocument source: Document) throws
    func meowSerialize() -> Document
}

public protocol Embeddable : Serializable {}
