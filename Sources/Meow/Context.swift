import Foundation
import MongoKitten
import NIO

// A 🐈 Context
public final class Context {
    
    public let manager: Manager
    
    public var eventLoop: EventLoop {
        return manager.eventLoop
    }
    
    internal init(_ manager: Manager) {
        self.manager = manager
    }
    
    /// The amount of objects to keep strong references to
    public var strongReferenceAmount = 0
    
    private var strongReferences = [_Model]()
    
    /// The internal storage that's used to hold metadata and references to objects
    internal private(set) var storage = [AnyInstanceIdentifier: (instance: Weak<AnyObject>, instantiation: Date)](minimumCapacity: 10)
    
    /// A set of entity's ids that are invalidated because they were removed
    private var invalidatedIdentifiers = Set<AnyInstanceIdentifier>()
    
    /// Instantiates a model from a Document unless the model is already in-memory
    func instantiateIfNeeded<M: Model>(type: M.Type, document: Document) throws -> M {
        guard let id = document["_id"] as? M.Identifier else {
            throw MeowError.missingOrInvalidValue(key: "_id", expected: M.Identifier.self, got: document["_id"])
        }
        
        let instanceIdentifier = InstanceIdentifier<M>(id)
        
        let existingInstance: M? = storage[instanceIdentifier]?.instance.value as? M
        
        // Return the existing instance from the pool if possible
        if let existingInstance = existingInstance {
            return existingInstance
        }
        
        // Decode the instance
        let decoder = M.decoder
        let instance = try decoder.decode(M.self, from: document)
        
        self.pool(instance)
        
        return instance
    }
    
    /// Stores an entity in the object pool
    public func pool<M: Model>(_ instance: M) {
        let instanceIdentifier = InstanceIdentifier<M>(instance._id)
        
        let current = storage[instanceIdentifier]?.instance.value
        
        // remove old strong reference
        if let current = current, let index = self.strongReferences.index(where: { $0 === current }) {
            self.strongReferences.remove(at: index)
        }
        
        // keep a strong reference
        if self.strongReferenceAmount > 0 {
            self.strongReferences.insert(instance, at: 0)
        }
        
        // clean up strong references
        if self.strongReferences.count > self.strongReferenceAmount {
            self.strongReferences.removeLast(self.strongReferences.count - self.strongReferenceAmount)
        }
        
        if let current = current {
            assert(current === instance, "two model instances with the same _id is invalid")
            return
        }
        
        // Only pool it if the instance is not invalidated
        if !invalidatedIdentifiers.contains(instanceIdentifier) {
            storage[instanceIdentifier] = (instance: Weak(instance), instantiation: Date())
        }
    }
    
    func getPooledInstance<M: Model>(withIdentifier id: M.Identifier) -> M? {
        let instanceIdentifier = InstanceIdentifier<M>(id)
        return storage[instanceIdentifier]?.instance.value as? M
    }
    
    /// Deletes the model resulting from the given query
    ///
    /// When the model has no registered pre- or postdelete hooks, the delete
    /// operation is forwarded 1:1 to the underlying collection.
    ///
    /// If the model has one or more pre- or postdelete hooks, a find operation
    /// is executed, and hooks are called while handling the delete operation.
    /// See `MeowHooks` for documentation on hooks.
    public func deleteOne<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> EventLoopFuture<Int> {
        return self.deleteOne(type, where: query.query)
    }
    
    /// Deletes the model resulting from the given query
    ///
    /// When the model has no registered pre- or postdelete hooks, the delete
    /// operation is forwarded 1:1 to the underlying collection.
    ///
    /// If the model has one or more pre- or postdelete hooks, a find operation
    /// is executed, and hooks are called while handling the delete operation.
    /// See `MeowHooks` for documentation on hooks.
    public func deleteOne<M: Model>(_ type: M.Type, where query: Query) -> EventLoopFuture<Int> {
        if MeowHooks.hasDeleteHooks(forType: type) {
            return self.findOne(type, where: query)
                .then { instance in
                    // Nothing to do if the instance does not exist
                    guard let instance = instance else {
                        return self.eventLoop.newSucceededFuture(result: 0)
                    }
                    
                    return self.delete(instance).map { 1 }
            }
        } else {
            return manager.collection(for: M.self).deleteOne(where: query)
        }
    }
    
    /// Deletes the models resulting from the given query
    ///
    /// When the model has no registered pre- or postdelete hooks, the delete
    /// operation is forwarded 1:1 to the underlying collection.
    ///
    /// If the model has one or more pre- or postdelete hooks, a find operation
    /// is executed, and hooks are called while handling the delete operation.
    /// See `MeowHooks` for documentation on hooks.
    public func deleteAll<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> EventLoopFuture<Int> {
        return self.deleteAll(type, where: query.query)
    }
    
    /// Deletes the models resulting from the given query
    ///
    /// When the model has no registered pre- or postdelete hooks, the delete
    /// operation is forwarded 1:1 to the underlying collection.
    ///
    /// If the model has one or more pre- or postdelete hooks, a find operation
    /// is executed, and hooks are called while handling the delete operation.
    /// See `MeowHooks` for documentation on hooks.
    public func deleteAll<M: Model>(_ type: M.Type, where query: Query) -> EventLoopFuture<Int> {
        if MeowHooks.hasDeleteHooks(forType: type) {
            var count = 0
            return self.find(type, where: query)
                .forEachAsync { instance in
                    count += 1
                    return self.delete(instance)
                }
                .map { count }
        } else {
            return manager.collection(for: M.self).deleteAll(where: query)
        }
    }
    
    /// Deletes the given model, calling any registered pre- or postdelete hooks
    public func delete<M: Model>(_ instance: M) -> EventLoopFuture<Void> {
        return MeowHooks.callPredeleteHooks(on: instance, context: self)
            .then {
                return self.manager.collection(for: M.self)
                    .deleteOne(where: "_id" == instance._id)
                    .map { _ in } // Count will always be 1 unless the object is already deleted
            }
            .then {
                MeowHooks.callPostdeleteHooks(on: instance, context: self)
        }
    }
    
    public func findOne<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> EventLoopFuture<M?> {
        return self.findOne(type, where: query.query)
    }
    
    public func findOne<M: Model>(_ type: M.Type, where query: Query = Query()) -> EventLoopFuture<M?> {
        if case .valEquals("_id", let val) = query {
            // Meow only supports one type as _id, so if it isn't an identifier we can safely return an empty result
            guard let _id = val as? M.Identifier else {
                return manager.eventLoop.newSucceededFuture(result: nil)
            }
            
            // we have this id in memory, so return that
            if let instance: M = getPooledInstance(withIdentifier: _id) {
                return manager.eventLoop.newSucceededFuture(result: instance)
            }
        }
        
        return manager.collection(for: M.self)
            .findOne(query)
            .thenThrowing { document -> M? in
                guard let document = document else {
                    return nil
                }
                
                return try self.instantiateIfNeeded(type: M.self, document: document)
        }
    }
    
    public func find<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> MappedCursor<FindCursor, M> {
        return self.find(type, where: query.query)
    }
    
    public func find<M: Model>(_ type: M.Type, where query: Query = Query()) -> MappedCursor<FindCursor, M> {
        return manager.collection(for: M.self)
            .find(query)
            .map { document in
                return try self.instantiateIfNeeded(type: M.self, document: document)
        }
    }
    
    public func findAllowingDecodeErrors<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> MappedCursor<FindCursor, DecodeResult<M>> {
        return self.findAllowingDecodeErrors(type, where: query.query)
    }
    
    public func findAllowingDecodeErrors<M: Model>(_ type: M.Type, where query: Query = Query()) -> MappedCursor<FindCursor, DecodeResult<M>> {
        return manager.collection(for: M.self)
            .find(query)
            .map { document in
                do {
                    let instance = try self.instantiateIfNeeded(type: M.self, document: document)
                    return .success(instance)
                } catch {
                    return .failure(error, document)
                }
        }
    }
    
    public func count<M: Model>(_ type: M.Type, where query: ModelQuery<M>) -> EventLoopFuture<Int> {
        return self.count(type, where: query.query)
    }
    
    public func count<M: Model>(_ type: M.Type, where query: Query = Query()) -> EventLoopFuture<Int> {
        return manager.collection(for: M.self).count(query)
    }
    
    /// Saves the `instance` to the database. If the collection already
    /// contains a value with the same `_id`, it is replaced by `instance`.
    ///
    /// Internally, this uses an `upsert`.
    ///
    /// ## Hooks
    ///
    /// Before saving, `willSave` is called on the `instance.` Then, any
    /// registered presave hooks for the type (`M`) are called.
    ///
    /// When all presave hooks succeed, the actual `upsert` takes place.
    public func save<M: Model>(_ instance: M) -> EventLoopFuture<Void> {
        self.pool(instance)
        
        return MeowHooks.callPresaveHooks(on: instance, context: self).then {
            do {
                let encoder = M.encoder
                let document = try encoder.encode(instance)
                
                return self.manager.collection(for: M.self)
                    .upsert(where: "_id" == instance._id, to: document)
                    .then { _ in
                        return MeowHooks.callPostsaveHooks(on: instance, context: self)
                }
            } catch {
                return self.manager.eventLoop.newFailedFuture(error: error)
            }
        }
    }
    
    /// Updates the given `fields` on the `instance`. This requires that
    /// the instance is already present in the database, because it internally
    /// uses an update operation with a `$set` command.
    ///
    /// No hooks are called for an `update` operation.
    ///
    /// - parameter instance: The instance to update
    /// - parameter fields: A list of fields to update. Field names need to match with the database keys. Only top level fields can be updated.
    public func update<M: Model>(_ instance: M, fields: String...) -> EventLoopFuture<Void> {
        self.pool(instance)
        
        assert(fields.allSatisfy { !$0.contains(".") }, "Updating nested fields is not supported")

        do {
            let encoder = M.encoder
            var document = try encoder.encode(instance)
            
            var set = [String: Primitive?]()
            
            var unsetKeys = Set(fields)
            
            for key in document.keys where fields.contains(key) {
                set[key] = document[key]
                unsetKeys.remove(key)
            }
            
            for key in unsetKeys {
                set[key] = .some(nil)
            }
            
            return self.manager.collection(for: M.self)
                .update(where: "_id" == instance._id, setting: set)
                .map { _ in }
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
}

public enum DecodeResult<M> {
    case success(M)
    case failure(Error, Document)
}
