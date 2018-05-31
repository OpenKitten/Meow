@_exported import MongoKitten
import NIO

/// A Meow
// TODO: Rename?
public final class Manager {
    
    var eventLoop: EventLoop {
        return database.connection.eventLoop
    }
    
    public let database: Database
    
    private init(database: Database) {
        self.database = database
    }
    
    public static func make(settings: ConnectionSettings, eventLoop: EventLoop) -> EventLoopFuture<Manager> {
        // Connect to the database first, the construct the actual manager
        return Database.connect(settings: settings, on: eventLoop).map { database in
            return Manager(database: database)
        }
    }
    
    public func makeContext() -> Context {
        return Context(self)
    }
    
    public func collection<M: Model>(for model: M.Type) -> MongoKitten.Collection {
        return database[M.collectionName]
    }
    
}
