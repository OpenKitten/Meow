//
//  Reference.swift
//  Meow
//
//  Created by Robbert Brandsma on 04-01-17.
//
//

import Foundation

public protocol DeleteRule {}

/// When the object containing the reference is deleted, this reference will be resolved and also deleted. This effect can cascade across multiple entities.
public enum Cascade : DeleteRule {}

/// When the object containing the reference is deleted, this reference will block deletion when it is not nil
public enum Deny : DeleteRule {}

/// When the object containing the reference is deleted, this referenced object will not have any action applied
public enum Ignore : DeleteRule {}

/// A reference to any (other) model
///
/// The DeleteRule specified removal behaviour as specified above
public final class Reference<M : ConcreteModel, D : DeleteRule> {
    public var id: ObjectId
    
    public init(_ instance: M) {
        self.id = instance.id
    }
    
    public init(restoring id: ObjectId) {
        self.id = id
    }
    
    /// Resolves this reference to a concretre object and throws if it doesn't exist (anymore)
    public func resolve() throws -> M {
        guard let instance = try M.findOne("_id" == id) else {
            throw Meow.Error.referenceError(id: id, type: M.self)
        }
        
        return instance
    }
    
    public var destinationType: M.Type { return M.self }
    public var deleteRule: D.Type { return D.self }
    
    public typealias Model = M
    public typealias DeleteRule = D
    
}
