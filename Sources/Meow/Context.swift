import Foundation
import MongoKitten
import NIO

// A 🐈 Context
public final class Context {
    
    var manager: Manager
    
    internal init(_ manager: Manager) {
        self.manager = manager
    }
    
    /// The amount of objects to keep strong references to
    public var strongReferenceAmount = 0
    
    private var strongReferences = [_Model]()
    
    /// The internal storage that's used to hold metadata and references to objects
    internal private(set) var storage = [AnyInstanceIdentifier: (instance: Weak<AnyObject>, instantiation: Date)](minimumCapacity: 10)
    
    /// A set of entity's ObjectIds that are invalidated because they were removed
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
    
    public func findOne<M: Model>(_ type: M.Type, query: Query = Query()) -> EventLoopFuture<M?> {
        if case .valEquals("_id", let val) = query.aqt {
            // Meow only supports on type as _id, so if it isn't an identifier we can safely return an empty result
            guard let _id = val as? M.Identifier else {
                return manager.eventLoop.newSucceededFuture(result: nil)
            }
            
            // we have this id in memory, so return that
            if let instance: M = getPooledInstance(withIdentifier: _id) {
                return manager.eventLoop.newSucceededFuture(result: instance)
            }
        }
        
        return manager.collection(for: M.self)
            .then { $0.findOne(query) }
            .thenThrowing { document -> M? in
                guard let document = document else {
                    return nil
                }
                
                return try self.instantiateIfNeeded(type: M.self, document: document)
        }
    }
    
    public func count<M: Model>(_ type: M.Type, query: Query = Query()) throws -> EventLoopFuture<Int> {
        return manager.collection(for: M.self)
            .then { $0.count(query) }
    }
    
    public func save<M: Model>(_ instance: M) -> EventLoopFuture<Void> {
        self.pool(instance)
        return self.manager.collection(for: M.self).thenThrowing { collection in
            try instance.willSave(with: self)
            
            let encoder = M.encoder
            let document = try encoder.encode(instance)
            
            collection.upsert("_id" == instance._id, to: document)
            
            try instance.didSave(with: self)
        }
    }
    
}
