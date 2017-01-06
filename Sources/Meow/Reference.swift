//
//  Reference.swift
//  Meow
//
//  Created by Robbert Brandsma on 04-01-17.
//
//

import Foundation

public protocol DeleteRule {}
public enum Cascade : DeleteRule {}
public enum Deny : DeleteRule {}
public enum Ignore : DeleteRule {}

public final class Reference<M : ConcreteModel, D : DeleteRule> {
    public var id: ObjectId
    
    public init(_ instance: M) {
        self.id = instance.id
    }
    
    public init(restoring id: ObjectId) {
        self.id = id
    }
    
    public func resolve() throws -> M {
        guard let instance = try M.findOne(matching: "_id" == id) else {
            throw Meow.Error.referenceError(id: id, type: M.self)
        }
        
        return instance
    }
    
    public var destinationType: M.Type { return M.self }
    public var deleteRule: D.Type { return D.self }
    
    public typealias Model = M
    public typealias DeleteRule = D
    
}
