//
//  DatabaseValidator.swift
//  Meow
//
//  Created by Robbert Brandsma on 02-05-17.
//
//

import Foundation

extension Meow {
    public typealias DatabaseProblem = (model: BaseModel.Type?, id: BSON.Primitive?, error: Swift.Error)
    
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
            print("Validating \(M)")
            for document in try M.collection.find() {
                do {
                    _ = try M.instantiateIfNeeded(document)
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
