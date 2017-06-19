//
//  DatabaseValidator.swift
//  Meow
//
//  Created by Robbert Brandsma on 19-06-17.
//

import Foundation

extension Meow {
    /// A problem found when validating the database
    public typealias DatabaseProblem = (model: _Model.Type?, id: BSON.Primitive?, error: Swift.Error)
    
    /// The error found
    enum ValidationError : Swift.Error {
        case cannotValidateBecauseOfAliveObjects(objects: [Any])
        case circularReference(stillAlive: Any)
    }
    
    /// Validates the integrity of the database and returns an array all problems
    public static func validateDatabaseIntegrity(problemLimit limit: Int = Int.max, types: [_Model.Type]) throws -> [DatabaseProblem] {
        guard Meow.pool.count == 0 else {
            throw ValidationError.cannotValidateBecauseOfAliveObjects(objects: Meow.pool.storage.map { $0.1 })
        }
        
        var problems = [DatabaseProblem]()
        
        upperLoop: for M in types {
            Meow.log("Validating \(M)")
            for document in try M.collection.find() {
                do {
                    let instance = try M.instantiateIfNeeded(document: document)
                    Meow.pool.ghost(instance)
                } catch {
                    problems.append((M, document["_id"], error))
                    
                    guard problems.count < limit else {
                        break upperLoop
                    }
                }
            }
        }
        
        // The pool should be empty again!
        for (_, instance) in Meow.pool.storage {
            problems.append((model: type(of: instance.instance.value) as? _Model.Type, id: (instance.instance.value as? _Model)?._id, error: ValidationError.circularReference(stillAlive: instance)))
        }
        
        return problems
    }
}
