import BSON
import Cheetah
import MongoKitten
import Foundation

extension GridFS {
    public static let `default`: GridFS = {
        return try! Meow.database.makeGridFS()
    }()
    
    public func readFile(from specification: ObjectId) throws -> AnyIterator<[UInt8]>? {
        guard let id = ObjectId(specification) else {
            return nil
        }
        
        guard let file = try self.findOne(byID: id) else {
            return nil
        }
        
        let iterator = try file.chunked()
        
        return AnyIterator {
            return iterator.next()?.data
        }
    }
    
    public func storeFile(withData data: Data) throws -> ObjectId {
        return try self.store(data: data)
    }
}

public protocol ByteSize {
    static var amount: Int { get }
}

public protocol FileLimits {
    static var mimeType: String { get }
    static var maximumByteSize: Int { get }
}

public enum MegaByte : ByteSize {
    public static var amount: Int {
        return 1_000_000
    }
}

public enum JPEG<B: ByteSize> : FileLimits {
    public static var mimeType: String {
        return "image/jpeg"
    }
    
    public static var maximumByteSize: Int {
        return B.amount
    }
}

public enum PNG<B: ByteSize> : FileLimits {
    public static var mimeType: String {
        return "image/png"
    }
    
    public static var maximumByteSize: Int {
        return B.amount
    }
}

public struct File<Limits: FileLimits> : SimplePrimitive {
    public func convert<S>(_ type: S.Type) -> S? {
        return specification.convert(type)
    }

    public let specification: ObjectId
    
    public init?(_ specification: Primitive?) {
        guard let specification = ObjectId(specification) else {
            return nil
        }
        
        self.specification = specification
    }
    
    public init(_ specification: ObjectId) {
        self.specification = specification
    }
    
    public static func store(_ data: Data) throws -> File<Limits> {
        guard data.count <= Limits.maximumByteSize else {
            throw Meow.Error.fileTooLarge(size: data.count, maximum: Limits.maximumByteSize)
        }
        
        let specification = try GridFS.default.storeFile(withData: data)
        
        return self.init(specification)
    }
    
    public var typeIdentifier: Byte {
        return specification.typeIdentifier
    }
    
    public func makeBinary() -> Bytes {
        return specification.makeBinary()
    }
}

//public protocol PublicallyExposed {
//    var bsonRepresentation: Primitive { get }
//    var jsonRepresentation: Cheetah.Value { get }
//    
//    init?(_ json: Cheetah.Value) throws
//    init?(_ bson: Primitive) throws
//}
//
//public struct File : PublicallyExposed {
//    public init?(_ json: Value) throws {
//        guard let id = String(json) else {
//            return nil
//        }
//        
//        self.id = try ObjectId(id)
//    }
//    
//    public init?(_ bson: Primitive) throws {
//        guard let id = ObjectId(bson) else {
//            return nil
//        }
//        
//        self.id = id
//    }
//
//    public let id: ObjectId
//    
//    public var bsonRepresentation: Primitive {
//        return id.hexString
//    }
//    
//    public var jsonRepresentation: Cheetah.Value {
//        return id.hexString
//    }
//    
//    public init() {
//        self.id = ObjectId()
//    }
//    
//    public init?(_ primitive: Primitive?) throws {
//        guard let id = ObjectId(primitive) else {
//            return nil
//        }
//        
//        self.id = id
//    }
//}
//
//extension URL : PublicallyExposed {
//    public init?(_ bson: Primitive) throws {
//        guard let string = String(bson) else {
//            return nil
//        }
//        
//        self.init(string: string)
//    }
//    
//    public init?(_ json: Cheetah.Value) throws {
//        guard let string = String(json) else {
//            return nil
//        }
//        
//        self.init(string: string)
//    }
//    
//    public var bsonRepresentation: Primitive {
//        return self.absoluteString
//    }
//    
//    public var jsonRepresentation: Cheetah.Value {
//        return self.absoluteString
//    }
//}

//Goede permissions in Vapor integratie, support voor allerlei typen relations, battle (en unit) tested, ondersteuning voor allerlei typen embeddables, support voor common types (URL, Data, Request, Dictionary, Set, NSPredicate, NSDictionary, NSArray, URLSession, Unit, alles wat NSCoding ondersteunt, UUID), ik wil suggested indexes, performance optimization, migrations, generated API documentation
