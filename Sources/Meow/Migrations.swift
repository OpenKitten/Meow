import Foundation
import MongoKitten
import NIO

enum MigrationError: Error {
    case noDefaultValueFound
}

fileprivate struct EncodingHelper<V: Encodable>: Encodable {
    var boxedValue: V
}

public class Migrator<M: Model> {
    
    public typealias Action = (MongoKitten.Collection) throws -> EventLoopFuture<Void>
    
    public let context: Context
    
    public init(context: Context) {
        self.context = context
    }
    
    private var actions = [Action]()
    
    func execute() -> EventLoopFuture<Void> {
        return context.manager.collection(for: M.self).then { collection in
            let promise: EventLoopPromise<Void> = self.context.eventLoop.newPromise()
            
            var actions = self.actions
            func doNextAction() {
                do {
                    guard actions.count > 0 else {
                        promise.succeed(result: ())
                        return
                    }
                    
                    let action = actions.removeFirst()
                    let actionResult = try action(collection)
                    actionResult.cascadeFailure(promise: promise)
                    actionResult.whenSuccess {
                        doNextAction()
                    }
                } catch {
                    promise.fail(error: error)
                }
            }
            
            doNextAction()
            
            return promise.futureResult
        }
    }
    
    public func add(_ action: @escaping Action) {
        actions.append(action)
    }
    
}

public extension Migrator where M: QueryableModel {
    
    public func ensureValue<V: Encodable>(for keyPath: KeyPath<M, V>, default value: V) {
        add { collection in
            let path = try M.makeQueryPath(for: keyPath)
            
            let helper = EncodingHelper(boxedValue: value)
            let encodedBox = try M.encoder.encode(helper)
            
            guard let encodedValue = encodedBox["boxedValue"] else {
                throw MigrationError.noDefaultValueFound
            }
    
            return collection.update(path == nil, setting: [path: encodedValue], multiple: true).map { _ in () }
        }
    }
    
}

extension Context {
    
    fileprivate var migrationsCollection: EventLoopFuture<MongoKitten.Collection> {
        return self.manager.database.map { $0["MeowMigrations"] }
    }
    
    /// Runs a migration closure that is not tied to a certain model
    /// The closure will be executed only once, because the migration is registered in the MeowMigrations collection
    public func migrateCustom(_ description: String, migration: @escaping () throws -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
        let fullDescription = "Custom - \(description)"
        return migrationsCollection
            .then { $0.count("_id" == fullDescription) }
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
                                "_id": fullDescription,
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
    
    public func migrate<M: Model>(_ description: String, on model: M.Type, migration: @escaping (Migrator<M>) throws -> Void) -> EventLoopFuture<Void> {
        let fullDescription = "\(M.self) - \(description)"
        
        return migrationsCollection
            .then { $0.count("_id" == fullDescription) }
            .then { count in
                if count > 0 {
                    // Migration not needed
                    // TODO: Log?
                    return self.manager.eventLoop.newSucceededFuture(result: ())
                }
                
                do {
                    let start = Date()
                    let migrator = Migrator<M>(context: self)
                    try migration(migrator)
                    
                    return migrator.execute().then {
                        let end = Date()
                        
                        let duration = end.timeIntervalSince(start)
                        
                        return self.migrationsCollection.then {
                            return $0.insert([
                                "_id": fullDescription,
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
