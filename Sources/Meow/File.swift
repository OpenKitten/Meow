import Cheetah
import MongoKitten
import Foundation

/// Allows embedding custom structures
internal protocol ValueConvertible : BSON.Primitive {
    var primitive: BSON.Primitive { get }
}

extension ValueConvertible {
    /// Converts the custom structure
    public func convert<DT>(to type: DT.Type) -> DT.SupportedValue? where DT : DataType {
        return primitive.convert(to: type)
    }
    
    /// The custom structure's type identifier
    public var typeIdentifier: Byte {
        return primitive.typeIdentifier
    }
    
    /// The custom structure's binary form
    public func makeBinary() -> Bytes {
        return primitive.makeBinary()
    }
}

extension GridFS {
    /// The default Meow GridFS instance.
    public static var `default`: GridFS = {
        return try! Meow.database.makeGridFS()
    }()
}

/// A GridFS file reference
public struct File : ValueConvertible {
    /// Initialized from JSON
    public init?(_ json: Value) throws {
        guard let id = String(json) else {
            return nil
        }
        
        self.id = try ObjectId(id)
    }
    
    /// The GridFS identifier
    public let id: ObjectId
    
    /// Converts this File to a primitive
    var primitive: BSON.Primitive {
        return self.id
    }
    
    /// Creates a new file
    public init() {
        self.id = ObjectId()
    }
    
    /// Initializes thie File from a primitive
    public init?(_ primitive: Primitive?) throws {
        guard let id = ObjectId(primitive) else {
            return nil
        }
        
        self.id = id
    }
}

/// Adds Meow embeddability to File
extension File : Serializable {
    /// Deserialized from a Primitive
    public init(restoring source: BSON.Primitive) throws {
        guard let id = ObjectId(source) else {
            throw Meow.Error.missingOrInvalidValue(key: "")
        }
        
        self.id = id
    }
    
    /// Serializes to a primitive
    public func serialize() -> Primitive {
        return id
    }
}
