import MongoKitten

extension MongoKitten.Collection {
    var model: BaseModel.Type? {
        return Meow.types.flatMap{ $0 as? BaseModel.Type }.first{ $0.collection.fullName == self.fullName }
    }
}

extension DBRef {
    public func resolveModel() throws -> BaseModel {
        guard let M = collection.model, let instance = try M.findOne("_id" == id) else {
            throw Meow.Error.brokenReference(in: [self])
        }
        
        return instance
    }
}

public struct Reference<M: Model> : Serializable, Hashable {
    let reference: ObjectId
    
    public static func ==(lhs: Reference<M>, rhs: Reference<M>) -> Bool {
        return lhs.reference == rhs.reference
    }
    
    public var hashValue: Int {
        return reference.hashValue
    }
    
    public init(to entity: M) {
        reference = entity._id
    }
    
    public init(restoring source: Primitive) throws {
        let document = try Meow.Helpers.requireValue(source as? Document, keyForError: "reference to \(M.self)")
        let ref = try Meow.Helpers.requireValue(DBRef(document, inDatabase: Meow.database), keyForError: "reference to \(M.self)")
        self.reference = try Meow.Helpers.requireValue(ref.id as? ObjectId, keyForError: "ObjectId for reference to \(M.self)")
    }
    
    public func serialize() -> Primitive {
        return DBRef(referencing: reference, inCollection: M.collection)
    }
    
    public func resolve() throws -> M {
        guard let referenced = try M.findOne("_id" == reference) else {
            throw Meow.Error.referenceError(id: reference, type: M.self)
        }
        
        return referenced
    }
}
