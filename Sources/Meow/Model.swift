@_exported import MongoKitten

/// When implemented, indicated that this is a model that resides at the lowest level of a collection, as a separate entity.
///
/// Embeddables will have a generated Virtual variant of itself for the type safe queries
public protocol Model : class, Serializable, Primitive {
    /// The database identifier. You do **NOT** need to add this yourself. It will be implemented for you.
    var _id: ObjectId { get set }
    
    /// The collection this entity resides in
    static var collection: MongoKitten.Collection { get }
    
    func serialize() -> Document
}

extension Model {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs._id == rhs._id
    }
    
    public static func ==(lhs: Self?, rhs: Self) -> Bool {
        return lhs?._id == rhs._id
    }
    
    public static func ==(lhs: Self, rhs: Self?) -> Bool {
        return lhs._id == rhs?._id
    }
}

public typealias ReferenceValues = [(key: String, destinationType: Model.Type, deleteRule: DeleteRule.Type, id: ObjectId)]

/// Implementes basic CRUD functionality for the object
extension Model {
    public func serialize() -> Primitive {
        return self.serialize() as Document
    }
    
    public func convert<DT>(to type: DT.Type) -> DT.SupportedValue? where DT : DataType {
        return self.serialize().convert(to: type)
    }
    
    public var typeIdentifier: Byte {
        return 0x03 // document
    }
    
    public func makeBinary() -> Bytes {
        return self.serialize().makeBinary()
    }
    
    /// Counts the amount of objects matching the query
    public static func count(_ filter: Query? = nil, limiting limit: Int? = nil, skipping skip: Int? = nil) throws -> Int {
        return try collection.count(filter, limiting: limit, skipping: skip)
    }
    
    /// Saves this object
    public func save() throws {
        let document = self.serialize()
        
        Meow.pool.pool(self)
        
        try Self.collection.update("_id" == self._id,
            to: document,
            upserting: true
        )
    }
    
    /// Removes all entities matching this query until `limit` has been reached
    public static func remove(_ query: Query, limitedTo limit: Int = 0) throws -> Int {
        return try collection.remove(query, limiting: limit)
    }
    
    /// Updates all entities in this collection to the provided Document
    public static func update(_ query: Query, to document: Document, multiple: Bool = false) throws -> Int {
        return try collection.update(query, to: document, upserting: false, multiple: multiple)
    }
    
    /// Returns all objects matching the query
    public static func find(_ query: Query? = nil) throws -> CollectionSlice<Self> {
        return try collection.find(query).flatMap { document in
            do {
                return try Meow.pool.instantiateIfNeeded(type: Self.self, document: document)
            } catch {
                print("initializing from document failed: \(error)")
                assertionFailure()
                return nil
            }
        }
    }
    
    /// Returns the first object matching the query
    public static func findOne(_ query: Query? = nil) throws -> Self? {
        return try Self.find(query).makeIterator().next()
    }
    
    /// Returns `true` if the object can be deleted, `false` otherwise
    public var canBeDeleted: Bool {
        do {
            _ = try self.validateDeletion()
        } catch {
            return false
        }
        
        return true
    }
    
    /// Validates if this object can be deleted
    ///
    /// - parameter keyPrefix: The string will be prefixed to all keys in thrown errors
    /// - returns: A closure that will correctly commit the deletion and its cascades
    public func validateDeletion(keyPrefix: String = "") throws -> (() throws -> ()) {
        fatalError("unimplemented")
//        // We'll store the actual deletion as a recursive closure, starting with ourselves:
//        var cascade: (() throws -> ()) = {
//            try Self.collection.remove("_id" == self._id)
//        }
//        
//        let referenceValues = self.meowReferencesWithValue
//        for (key, type, deleteRule, id) in referenceValues {
//            // Ignore rules should be, well... ignored
//            if deleteRule == Ignore.self {
//                continue
//            }
//            
//            guard let referee = try type.findOne("_id" == id) else {
//                continue
//            }
//            
//            // A deny should prevent deletion so we throw an error, making deletion impossible
//            if deleteRule == Deny.self {
//                throw Meow.Error.undeletableObject(reason: keyPrefix + key)
//            }
//            
//            // Cascades should be prefixed to our own cascade closure, so we'll do just that
//            if deleteRule == Cascade.self {
//                let thisCascade = try referee.validateDeletion(keyPrefix: key + ".")
//                cascade = {
//                    try thisCascade()
//                    try cascade()
//                }
//            }
//        }
//        
//        return cascade
    }
    
    /// Removes this object from the database
    public func delete() throws {
        try self.validateDeletion()()
    }
}
