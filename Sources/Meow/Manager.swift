@_exported import MongoKitten
import NIO

/// A Meow
// TODO: Rename?
public final class Manager {
    
    let eventLoop: EventLoop
    let connectionSettings: ConnectionSettings
    
    public lazy var database: EventLoopFuture<Database> = {
        let future = Database.connect(settings: connectionSettings, on: eventLoop)
        self.database = future
        
        return future
    }()
    
    public init(settings: ConnectionSettings, eventLoop: EventLoop) {
        self.connectionSettings = settings
        self.eventLoop = eventLoop
    }
    
    public func makeContext() -> Context {
        return Context(self)
    }
    
}
