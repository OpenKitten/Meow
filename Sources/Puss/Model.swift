@_exported import MongoKitten

public protocol Model : class {
    var id: ObjectId { get set }
}

public typealias ReferenceValues = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]

public protocol ConcreteModel : Model {
    static var pussCollection: MongoKitten.Collection { get }
    init(fromDocument source: Document) throws
    func pussSerialize() -> Document
    var pussReferencesWithValue: ReferenceValues { get }
}

public protocol FieldSet {
    var fieldName: String { get }
}

extension ConcreteModel {
    public static func count(matching filter: Query? = nil, limitedTo limit: Int32? = nil, skipping skip: Int32? = nil) throws -> Int {
        return try pussCollection.count(matching: filter, limitedTo: limit, skipping: skip)
    }
    
    public func save() throws {
        let document = pussSerialize()
        
        try Self.pussCollection.update(
            matching: "_id" == self.id,
            to: document,
            upserting: true
        )
    }
    
    public static func find(matching query: Query? = nil) throws -> Cursor<Self> {
        let originalCursor = try pussCollection.find(matching: query)
        
        return Cursor(base: originalCursor) { document in
            return try? Self.init(fromDocument: document)
        }
    }
    
    public static func findOne(matching query: Query? = nil) throws -> Self? {
        return try Self.find(matching: query).makeIterator().next()
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
        // We'll store the actual deletion as a recursive closure, starting with ourselves:
        var cascade: (() throws -> ()) = {
            try self.delete()
        }
        
        let referenceValues = self.pussReferencesWithValue
        for (key, type, deleteRule, id) in referenceValues {
            // Ignore rules should be, well... ignored
            if deleteRule == Ignore.self {
                continue
            }
            
            guard let referee = try type.findOne(matching: "_id" == id) else {
                continue
            }
            
            // A deny should prevent deletion so we throw an error, making deletion impossible
            if deleteRule == Deny.self {
                throw Puss.Error.undeletableObject(reason: keyPrefix + key)
            }
            
            // Cascades should be prefixed to our own cascade closure, so we'll do just that
            if deleteRule == Cascade.self {
                let thisCascade = try referee.validateDeletion(keyPrefix: key + ".")
                cascade = {
                    try thisCascade()
                    try cascade()
                }
            }
        }
        
        return cascade
    }
    
    public func delete() throws {
        try self.validateDeletion()()
    }
}
