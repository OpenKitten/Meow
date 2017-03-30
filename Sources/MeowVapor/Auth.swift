import Foundation
import HTTP
import Vapor
import Meow

public typealias RequirementsChecker = ((Any) throws -> (Bool))

extension Meow {
    public static func currentUser() -> Authenticatable? {
        return (Thread.current as? ContextThread)?.request.storage["meowUser"] as? Authenticatable
    }
}

extension Request {
    public var authenticationRequired: Bool {
        return true
    }
}

public protocol Authenticatable : Model {
    static func authenticate(_ request: Request) throws -> Self
    static func byIdentifier(_ id: ObjectId) throws -> Self?
}

extension Authenticatable {
    public func current() -> Self? {
        return Meow.currentUser as? Self
    }
}

public class AuthenticationMiddleware {
    public static let `default` = AuthenticationMiddleware()
    
    public var onAuthenticationRequired: ((Any) throws -> ResponseRepresentable) = { _ in
        throw Abort.unauthorized
    }
    
    public var enabled: Bool = false
    
    public var authenticationRequired: RequirementsChecker = { _ in
        return true
    }
    
    public var authenticables = [String: Authenticatable.Type]()
    
    init() { }
    
    public func respond(to request: Request, route: Any, chainingTo next: @escaping ((Request) throws -> ResponseRepresentable)) throws -> ResponseRepresentable {
        guard enabled else {
            return try next(request)
        }
        
        func fail() throws -> ResponseRepresentable {
            if request.authenticationRequired {
                return try onAuthenticationRequired(route)
            } else {
                return try next(request)
            }
        }
        
        guard let userSession = Document(try request.session().document["meow"]["user"]), let authenticationID = ObjectId(userSession["_id"]), let typeName = String(userSession["type"]) else {
            return try fail()
        }
        
        guard let type = authenticables[typeName] else {
            return try fail()
        }
        
        guard let user = try type.byIdentifier(authenticationID) else {
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
