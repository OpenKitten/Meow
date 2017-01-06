//
//  Embeddable.swift
//  Puss
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation

public protocol Serializable {}

public protocol ConcreteSerializable {
    init(fromDocument source: Document) throws
    func pussSerialize() -> Document
}

public protocol Embeddable : Serializable {}
