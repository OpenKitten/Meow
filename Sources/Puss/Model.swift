@_exported import MongoKitten

public protocol Model : class {
    var id: ObjectId { get set }
}

public protocol ConcreteModel : Model {
    static var pussCollection: MongoKitten.Collection { get }
    init(fromDocument source: Document) throws
    func pussSerialize() -> Document
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
    
    public static func find() throws -> Cursor<Self> {
        let originalCursor = try pussCollection.find()
        
        return Cursor(base: originalCursor) { document in
            return try? Self.init(fromDocument: document)
        }
    }
}
