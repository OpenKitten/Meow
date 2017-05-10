@_exported import MongoKitten

public protocol KeyRepresentable : Hashable {
    var keyString: String { get }
}

public protocol ModelKey : KeyRepresentable {
    var type: Any.Type { get }
    static var all: [Self] { get }
}

public protocol ModelValues : SerializableToDocument {
    init()
}

extension String : KeyRepresentable {
    public var keyString: String {
        return self
    }
}

extension ObjectId : KeyRepresentable {
    public var keyString: String {
        return hexString
    }
}

/// Something that can be saved
public protocol BaseModel : SerializableToDocument, Primitive {
    /// The collection this entity resides in
    static var collection: MongoKitten.Collection { get }
    
    /// Saves this object
    func save() throws
    
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    func willSave() throws
    
    /// Will be called when the Model has been saved to the database.
    func didSave() throws
    
    /// The database identifier. You do **NOT** need to add this yourself. It will be implemented for you using Sourcery.
    var _id: ObjectId { get set }
    
    /// Serialize the model into a Document
    func serialize() -> Document
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    func willDelete() throws
    
    /// Will be called when the Model is deleted. At this point, it is no longer in the database and saves will no longer work because the ObjectId is invalidated.
    func didDelete() throws
    
    init(newFrom source: BSON.Primitive) throws
    static func validateUpdate(with document: Document) throws
    func update(with document: Document) throws
}

/// When implemented, indicated that this is a model that resides at the lowest level of a collection, as a separate entity.
///
/// Embeddables will have a generated Virtual variant of itself for the type safe queries
public protocol Model : class, BaseModel, Hashable {
    associatedtype Key : ModelKey = String
    associatedtype VirtualInstance : VirtualModelInstance
    associatedtype Values : ModelValues
}

extension Model {
    public var keyString: String {
        return _id.hexString
    }
    
    public var hashValue: Int {
        return _id.hashValue
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs._id == rhs._id
    }
    
    public static func makeQuery(_ closure: ((VirtualInstance) throws -> (Query))) rethrows -> Query {
        return try closure(VirtualInstance(keyPrefix: ""))
    }
}

extension BaseModel {
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

public extension BaseModel {
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    public func willSave() throws {}
    
    /// Will be called when the Model has been saved to the database.
    public func didSave() throws {}
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    public func willDelete() throws {}
    
    /// Will be called when the Model is deleted. At this point, it is no longer in the database and saves will no longer work because the ObjectId is invalidated.
    public func didDelete() throws {}
}


/// Implementes basic CRUD functionality for the object
extension BaseModel {
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
    
    /// Removes this object from the database
    public func delete() throws {
        try self.willDelete()
        Meow.pool.invalidate(self._id)
        try Self.collection.remove("_id" == self._id)
        try self.didDelete()
    }
    
    /// Returns the first object matching the query
    public static func findOne(_ query: Query? = nil) throws -> Self? {
        // We don't reuse find here because that one does not have proper error reporting
        guard let document = try collection.findOne(query) else {
            return nil
        }
        
        return try Self.instantiateIfNeeded(document)
    }
    
    /// Saves this object
    public func save() throws {
        try self.willSave()
        print("🐈 Saving \(self)")
        
        let document = self.serialize()
        
        Meow.pool.pool(self)
        
        try Self.collection.update("_id" == self._id,
                                   to: document,
                                   upserting: true
        )
        
        try self.didSave()
    }
    
    /// Removes all entities matching the query
    /// Errors that happen during deletion will be collected and a `Meow.error.deletingMultiple` will be thrown if errors occurred
    public static func remove(_ query: Query? = nil, limitedTo limit: Int? = nil) throws {
        var errors = [(ObjectId, Error)]()
        for instance in try self.find(query, limitedTo: limit) {
            do {
                try instance.delete()
            } catch {
                errors.append((instance._id, error))
            }
        }
        
        guard errors.count == 0 else {
            throw Meow.Error.deletingMultiple(errors: errors)
        }
    }
    
    /// Returns all objects matching the query
    public static func find(_ query: Query? = nil, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100) throws -> CollectionSlice<Self> {
        return try collection.find(query, sortedBy: sort, skipping: skip, limitedTo: limit, withBatchSize: batchSize).flatMap { document in
            do {
                return try Self.instantiateIfNeeded(document)
            } catch {
                print("🐈 Initializing from document failed: \(error)")
                assertionFailure()
                return nil
            }
        }
    }
    
    public static func instantiateIfNeeded(_ document: Document) throws -> Self {
        return try Meow.pool.instantiateIfNeeded(type: Self.self, document: document)
    }
}
