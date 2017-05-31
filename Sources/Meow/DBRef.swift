import MongoKitten

extension DBRef : Serializable {
    public init(restoring source: BSON.Primitive, key: String) throws {
        self = try Meow.Helpers.requireValue(DBRef(source, inDatabase: Meow.database), keyForError: key)
    }
    
    public func serialize() -> Primitive {
        return self.documentValue
    }
}
