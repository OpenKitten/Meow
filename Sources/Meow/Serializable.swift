import Foundation
import BSON

/// Something that can be converted to and from a BSON Primitive
public protocol Serializable {
    /// Initialize an instance of the Serializable, restoring from the BSON Primitive format
    ///
    /// This initializer *must* only be called from within Meow. Never call this method fromy our application.
    init(restoring source: BSON.Primitive, key: String) throws
    
    /// Serialize the Serializable into its BSON Primitive format
    func serialize() -> BSON.Primitive
}

/// Something that can be restored using a static func instead of an init. Exists because we don't want Self or associated type requirements in `Serializable`.
public protocol Restorable : Serializable {
    static func restore(_ source: BSON.Primitive, key: String) throws -> Self
}

extension Restorable {
    public init(restoring source: BSON.Primitive, key: String) throws {
        self = try Self.restore(source, key: key)
    }
}

/// Something that can be converted to (and from) a Document
public protocol SerializableToDocument : Serializable {
    func serialize() -> BSON.Document
}

extension SerializableToDocument {
    /// A helper for the primitive serialization
    public func serialize() -> BSON.Primitive {
        return self.serialize() as Document
    }
}
