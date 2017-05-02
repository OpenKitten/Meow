import Foundation
import HTTP
import Vapor
import Meow

public typealias RequirementsChecker = ((Any) throws -> (Bool))

extension Meow {
    public static var currentUser: Authenticatable? {
        get {
            return (Thread.current as? ContextThread)?.request.storage["meowUser"] as? Authenticatable
        }
        set {
            (Thread.current as? ContextThread)?.request.storage["meowUser"] = newValue
            (Thread.current as? ContextThread)?.request.session?.document["meow"]["user"] = newValue?._id
        }
    }
}

public protocol Authenticatable : BaseModel {
    static func resolve(byId identifier: ObjectId) throws -> Self?
}

extension Authenticatable {
    public static func resolve(byId identifier: ObjectId) throws -> Self? {
        return try Self.findOne("_id" == identifier)
    }
}

extension Authenticatable {
    public static var current: Self? {
        return Meow.currentUser as? Self
    }
}

public class AuthenticationMiddleware {
    public static let `default` = AuthenticationMiddleware()
    
    public var onAuthenticationRequired: ((Any) throws -> ResponseRepresentable) = { _ in
        throw Abort.unauthorized
    }
    
    public var enabled: Bool = false
    
    public var models = [Authenticatable.Type]()
    
    public subscript(id: ObjectId) -> Authenticatable? {
        for model in models {
            if let entity = try? model.resolve(byId: id) {
                return entity
            }
        }
        
        return nil
    }
    
    public var authenticationRequired: RequirementsChecker = { _ in
        return true
    }
    
    init() { }
    
    public func respond(to request: Request, route: Any, chainingTo next: @escaping ((Request) throws -> ResponseRepresentable)) throws -> ResponseRepresentable {
        guard enabled else {
            return try next(request)
        }
        
        func fail() throws -> ResponseRepresentable {
            if try self.authenticationRequired(route) {
                return try onAuthenticationRequired(route)
            } else {
                return try next(request)
            }
        }
        
        guard let authenticationID = ObjectId(request.session?.document["meow"]["user"]) else {
            return try fail()
        }
        
        guard let user = self[authenticationID] else {
            return try fail()
        }
        
        request.storage["meowUser"] = user
        
        return try next(request)
    }
}

public class AuthorizationMiddleware {
    public static let `default` = AuthorizationMiddleware()
    
    public var enabled: Bool = false
    
    public var permissionChecker: RequirementsChecker = { _ in
        return false
    }
    
    public var onInsufficientPermissions: ((Any) throws -> ResponseRepresentable) = { _ in
        throw Abort.unauthorized
    }
    
    public func respond(to request: Request, route: Any, chainingTo next: @escaping ((Request) throws -> ResponseRepresentable)) throws -> ResponseRepresentable {
        guard enabled else {
            return try next(request)
        }
        
        guard try permissionChecker(route) else {
            return try onInsufficientPermissions(request)
        }
        
        return try next(request)
    }
    
    init() { }
}
