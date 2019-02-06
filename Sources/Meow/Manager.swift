@_exported import MongoKitten
import NIO
import Dispatch

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

extension Manager: EventLoopGroup {
    public func next() -> EventLoop {
        return self.eventLoop
    }
    
    public func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        eventLoop.shutdownGracefully(queue: queue, callback)
    }
}
