import MongoKitten
import Sessions
import Vapor
import Crypto

public class MongoSessions : SessionsProtocol {
    let collection: MongoKitten.Collection
    
    init(in collection: MongoKitten.Collection) {
        self.collection = collection
    }
    
    public func makeIdentifier() throws -> String {
        return try Crypto.Random.bytes(count: 20).base64Encoded.makeString()
    }
    
    public func get(identifier: String) throws -> Session? {
        guard var sessionDocument = try collection.findOne("_id" == identifier) else {
            return nil
        }
        
        sessionDocument.removeValue(forKey: "_id")
        
        return Session(identifier: identifier, data: Node([:], in: sessionDocument))
    }
    
    public func set(_ session: Session) throws {
        try collection.update("_id" == session.identifier, to: ["_id" : session.identifier] + session.document, upserting: true)
    }
    
    public func destroy(identifier: String) throws {
        try collection.remove("_id" == identifier)
    }
}

extension Session {
    var document: Document {
        get {
            return (self.data.context as? Document) ?? [:]
        }
        set {
            self.data.context = newValue
        }
    }
}

extension Document : Context {}
