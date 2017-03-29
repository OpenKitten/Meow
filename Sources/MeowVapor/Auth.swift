import Foundation
import HTTP
import Vapor
import Meow

public typealias PermissionCheck = ((Request) throws -> (Bool))

public class PermissionChecker<A: Account> : Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard try check(request.storage["currentMeowUser"] as? A) else {
            throw Error.insufficientPermissions
        }
        
        return try next.respond(to: request)
    }

    public enum Error : Swift.Error {
        case insufficientPermissions
    }
    
    public typealias Checker = ((A?) throws -> (Bool))
    let check: Checker
    
    public init(checker: @escaping Checker) {
        self.check = checker
    }
}

public protocol Account {
    var uniqueIdentifier: String { get }
}

extension Account where Self : ConcreteModel {
    public var uniqueIdentifier: String {
        return self._id.hexString
    }
}

public protocol Permissions {
    init?(for request: Request) throws
}

extension Permissions {
    public var current: Self? {
        guard let request = (Thread.current as? ContextThread)?.request else {
            return nil
        }
        
        do {
            return try Self(for: request)
        } catch { return nil }
    }
}
