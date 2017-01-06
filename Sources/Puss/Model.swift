@_exported import MongoKitten

public protocol Model : class {
    var id: ObjectId { get set }
}

public protocol ConcreteModel : Model {
    static var pussCollection: MongoKitten.Collection { get }
    init(fromDocument source: Document) throws
    func pussSerialize() -> Document
    
//    associatedtype Fields : FieldSet
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
}
