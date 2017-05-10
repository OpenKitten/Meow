import Foundation
import BSON

public protocol Serializable {
    init(restoring source: BSON.Primitive) throws
    
    func serialize() -> BSON.Primitive
}

public protocol SerializableToDocument : Serializable {
    func serialize() -> BSON.Document
}

extension SerializableToDocument {
    public func serialize() -> BSON.Primitive {
        return self.serialize() as Document
    }
}
