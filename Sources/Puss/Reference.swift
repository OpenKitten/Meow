//
//  Reference.swift
//  Puss
//
//  Created by Robbert Brandsma on 04-01-17.
//
//

import Foundation

public final class Reference<M : ConcreteModel> {
    public var id: ObjectId
    
    public init(_ instance: M) {
        self.id = instance.id
    }
    
    public func resolve() throws -> M {
        guard let instance = try M.findOne(matching: "_id" == id) else {
            throw Puss.Error.referenceError(id: id, type: M.self)
        }
        
        return instance
    }
}
