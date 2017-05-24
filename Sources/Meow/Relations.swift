import MongoKitten

infix operator &=

/// Creates a reference to the rhs model and puts it in lhs
public func &=<M : Model>(lhs: inout Reference<M>, rhs: M) {
    lhs = Reference(to: rhs)
}

prefix operator *

/// Resolves the reference on the rhs
public prefix func *<M : Model>(_ reference: Reference<M>) throws -> M {
    return try reference.resolve()
}

extension MongoKitten.Collection {
    /// Gets the model for this collection
    public var model: BaseModel.Type? {
        return Meow.types.flatMap{ $0 as? BaseModel.Type }.first{ $0.collection.fullName == self.fullName }
    }
}

extension DBRef {
    /// Resolves the model referenced in this DBRef
    public func resolveModel() throws -> BaseModel {
        guard let M = collection.model, let instance = try M.findOne("_id" == id) else {
            throw Meow.Error.brokenReference(in: self)
        }
        
        return instance
    }
}

/// Reference to a Model
public struct Reference<M: BaseModel> : Serializable, Hashable, Identifyable {
    /// The referenced id
    let reference: ObjectId
    
    /// Compares two references to be referring to the same entity
    public static func ==(lhs: Reference<M>, rhs: Reference<M>) -> Bool {
        return lhs.reference == rhs.reference
    }
    
    /// Compares the rhs reference to refer to lhs
    public static func ==(lhs: M, rhs: Reference<M>) -> Bool {
        return lhs._id == rhs.reference
    }
    
    /// Compares the lhs reference to refer to rhs
    public static func ==(lhs: Reference<M>, rhs: M?) -> Bool {
        return lhs.reference == rhs?._id
    }
    
    /// Makes a reference hashable
    public var hashValue: Int {
        return reference.hashValue
    }
    
    /// Creates a reference from an entity
    public init(to entity: M) {
        reference = entity._id
    }
    
    /// Deserializes a reference
    public init(restoring source: Primitive, key: String) throws {
        let document = try Meow.Helpers.requireValue(Document(source), keyForError: key)
        self.reference = try Meow.Helpers.requireValue(ObjectId(document["_id"]), keyForError: key)
    }
    
    /// Serializes a reference
    public func serialize() -> Primitive {
        return [
            "_id": reference,
            "_ref": M.collection.name
        ]
    }
    
    /// Resolves a reference
    public func resolve() throws -> M {
        guard let referenced = try M.findOne("_id" == reference) else {
            throw Meow.Error.referenceError(id: reference, type: M.self)
        }
        
        return referenced
    }
    
    public var databaseIdentifier: ObjectId { return reference }
}
