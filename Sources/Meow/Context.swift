import Foundation

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
    public func instantiateIfNeeded<M: Model>(type: M.Type, document: Document) throws -> M {
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
    
}
