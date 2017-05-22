import Foundation

extension Meow {
    /// A problem found when validating the database
    public typealias DatabaseProblem = (model: BaseModel.Type?, id: BSON.Primitive?, error: Swift.Error)
    
    /// The error found
    enum ValidationError : Swift.Error {
        case cannotValidateBecauseOfAliveObjects(objects: [Any])
        case circularReference(stillAlive: Any)
    }
    
    /// Validates the integrity of the database and returns an array all problems
    public static func validateDatabaseIntegrity() throws -> [DatabaseProblem] {
        guard Meow.pool.count == 0 else {
            throw ValidationError.cannotValidateBecauseOfAliveObjects(objects: Meow.pool.storage.map { $0.1 })
        }
        
        var problems = [DatabaseProblem]()
        
        for M in Meow.types {
            guard let M = M as? BaseModel.Type else { continue }
            Meow.log("Validating \(M)")
            for document in try M.collection.find() {
                do {
                    let instance = try M.instantiateIfNeeded(document)
                    Meow.pool.ghost(instance)
                } catch {
                    problems.append((M, document["_id"], error))
                }
            }
        }
        
        // The pool should be empty again!
        for (_, instance) in Meow.pool.storage {
            problems.append((model: type(of: instance) as? BaseModel.Type, id: (instance as? BaseModel)?._id, error: ValidationError.circularReference(stillAlive: instance)))
        }
        
        return problems
    }
}
