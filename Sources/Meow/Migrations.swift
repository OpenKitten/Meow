import Foundation
import MongoKitten
import NIO

extension Context {
    
    fileprivate var migrationsCollection: MongoKitten.Collection { return self.manager.database["MeowMigrations"] }
    
    public func migrateCustom(_ description: String, migration: @escaping () throws -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
        return migrationsCollection.count().then { count in
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
                    
                    return self.migrationsCollection.insert([
                        "_id": description,
                        "date": start,
                        "duration": duration
                        ]).map { _ in () }
                }
            } catch {
                return self.manager.eventLoop.newFailedFuture(error: error)
            }
        }
    }
    
}
