@_exported import MongoKitten
import NIO

/// A Meow
public final class Manager {
    
    public var eventLoop: EventLoop { return database.eventLoop }
    public let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func makeContext() -> Context {
        return Context(self)
    }
    
    public func collection<M: Model>(for model: M.Type) -> MongoKitten.Collection {
        return database[M.collectionName]
    }
    
}
