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

extension Meow {
    /// The default Meow GridFS instance.
    public static var fs: GridFS = {
        return try! Meow.database.makeGridFS()
    }()
}

extension GridFS.File : Restorable {
    public static func restore(_ source: Primitive) throws -> GridFS.File {
        guard let id = ObjectId(source) else {
            throw Meow.Error.missingOrInvalidValue(key: "file")
        }
        
        guard let file = try Meow.fs.findOne(byID: id) else {
            throw Meow.Error.brokenFileReference(id)
        }
        
        return file
    }
    
    public func serialize() -> Primitive {
        return self.id
    }
}
