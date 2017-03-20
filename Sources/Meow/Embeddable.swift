//
//  Embeddable.swift
//  Meow
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation

/// A protocol that is merely used to indicate an extension point
public protocol Serializable {}

/// Allows (de-)serializing additional data that is not in the model
public protocol DynamicSerializable {
    var additionalFields: Document { get set }
}

/// Should be implemented in an extension by the generator.
///
/// When implemented, it allows conversion to and from a Document
public protocol ConcreteSerializable {
    init(fromDocument source: Document) throws
    func meowSerialize(resolvingReferences: Bool) throws -> Document
    func meowSerialize() -> Document
}

public protocol ConcreteSingleValueSerializable : Primitive {
    func meowSerialize(resolvingReferences: Bool) throws -> Primitive
    func meowSerialize() -> Primitive
}

extension ConcreteSingleValueSerializable {
    public func convert<DT>(to type: DT.Type) -> DT.SupportedValue? where DT : DataType {
        return self.meowSerialize().convert(to: type)
    }
    
    public var typeIdentifier: Byte {
        return meowSerialize().typeIdentifier
    }
    
    public func makeBinary() -> Bytes {
        return meowSerialize().makeBinary()
    }
}

/// An empty protocol indicating that this is not a Model but a value that lies embedded in a model
///
/// Embeddables will have a generated Virtual variant of itself for the type safe queries
public protocol Embeddable : Serializable {}
