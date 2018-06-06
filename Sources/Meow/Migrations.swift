import Foundation
import MongoKitten
import NIO

extension Context {
    
    fileprivate var migrationsCollection: EventLoopFuture<MongoKitten.Collection> {
        return self.manager.database.map { $0["MeowMigrations"] }
    }
    
    public func migrateCustom(_ description: String, migration: @escaping () throws -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
        return migrationsCollection
            .then { $0.count("_id" == description) }
            .then { count in
                if count > 0 {
                    // Migration not needed
                    // TODO: Log?
                    return self.manager.eventLoop.newSucceededFuture(result: ())
                }
                
                do {
                    let start = Date()
                    return try migration().then {
                        let end = Date()
                        
                        let duration = end.timeIntervalSince(start)
                        
                        return self.migrationsCollection.then {
                            return $0.insert([
                                "_id": description,
                                "date": start,
                                "duration": duration
                                ]).map { _ in () }
                            }
                    }
                } catch {
                    return self.manager.eventLoop.newFailedFuture(error: error)
                }
        }
    }
    
}
