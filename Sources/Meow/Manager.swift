@_exported import MongoKitten
import NIO

/// A Meow
public final class Manager {
    
    public let eventLoop: EventLoop
    public let database: EventLoopFuture<Database>
    
    public init(settings: ConnectionSettings, eventLoop: EventLoop) {
        self.database = Database.connect(settings: settings, on: eventLoop)
        self.eventLoop = eventLoop
    }
    
    public func makeContext() -> Context {
        return Context(self)
    }
    
    public func collection<M: Model>(for model: M.Type) -> EventLoopFuture<MongoKitten.Collection> {
        return database.map { $0[M.collectionName] }
    }
    
}
