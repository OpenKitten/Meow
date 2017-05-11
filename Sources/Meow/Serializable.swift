import Foundation
import BSON

/// Something that can be converted to and from a Primitive
public protocol Serializable {
    init(restoring source: BSON.Primitive) throws
    
    func serialize() -> BSON.Primitive
}

/// Something that can be converted to a Document and from a primitive
public protocol SerializableToDocument : Serializable {
    func serialize() -> BSON.Document
}

extension SerializableToDocument {
    /// A helper for the primitive serialization
    public func serialize() -> BSON.Primitive {
        return self.serialize() as Document
    }
}
