@_exported import MongoKitten
import NIO

/// A Meow
public final class Manager {
    
    public let eventLoop: EventLoop
    public let database: Database
    
    public init(database: Database) {
        self.database = database
        self.eventLoop = database.connection.eventLoop
    }
    
    public func makeContext() -> Context {
        return Context(self)
    }
    
    public func collection<M: Model>(for model: M.Type) -> MongoKitten.Collection {
        return database[M.collectionName]
    }
    
}
