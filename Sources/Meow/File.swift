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
    public static var `default`: GridFS = {
        return try! Meow.database.makeGridFS()
    }()
}

public struct File : ValueConvertible {
    public init?(_ json: Value) throws {
        guard let id = String(json) else {
            return nil
        }
        
        self.id = try ObjectId(id)
    }
    
    public let id: ObjectId
    
    var primitive: BSON.Primitive {
        return self.id
    }
    
    public init() {
        self.id = ObjectId()
    }
    
    public init?(_ primitive: Primitive?) throws {
        guard let id = ObjectId(primitive) else {
            return nil
        }
        
        self.id = id
    }
}

extension File : Serializable {
    public init(restoring source: BSON.Primitive) throws {
        guard let id = ObjectId(source) else {
            throw Meow.Error.missingOrInvalidValue(key: "")
        }
        
        self.id = id
    }
    
    public func serialize() -> Primitive {
        return id
    }
}
