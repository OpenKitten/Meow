import Cheetah
import MongoKitten
import Foundation

public protocol PublicallyExposed {
    var bsonRepresentation: Primitive { get }
    var jsonRepresentation: Cheetah.Value { get }
    
    init?(_ json: Cheetah.Value) throws
    init?(_ bson: Primitive) throws
}

public struct File : PublicallyExposed {
    public init?(_ json: Value) throws {
        guard let id = String(json) else {
            return nil
        }
        
        self.id = try ObjectId(id)
    }
    
    public init?(_ bson: Primitive) throws {
        guard let id = ObjectId(bson) else {
            return nil
        }
        
        self.id = id
    }

    public let id: ObjectId
    
    public var bsonRepresentation: Primitive {
        return id.hexString
    }
    
    public var jsonRepresentation: Cheetah.Value {
        return id.hexString
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

extension URL : PublicallyExposed {
    public init?(_ bson: Primitive) throws {
        guard let string = String(bson) else {
            return nil
        }
        
        self.init(string: string)
    }
    
    public init?(_ json: Cheetah.Value) throws {
        guard let string = String(json) else {
            return nil
        }
        
        self.init(string: string)
    }
    
    public var bsonRepresentation: Primitive {
        return self.absoluteString
    }
    
    public var jsonRepresentation: Cheetah.Value {
        return self.absoluteString
    }
}

//Goede permissions in Vapor integratie, support voor allerlei typen relations, battle (en unit) tested, ondersteuning voor allerlei typen embeddables, support voor common types (URL, Data, Request, Dictionary, Set, NSPredicate, NSDictionary, NSArray, URLSession, Unit, alles wat NSCoding ondersteunt, UUID), ik wil suggested indexes, performance optimization, migrations, generated API documentation

@available(OSX 10.12, *)
extension Unit {
    public var bsonRepresentation: Primitive {
        return self.symbol
    }
    
    public var jsonRepresentation: Value {
        return self.symbol
    }
}
