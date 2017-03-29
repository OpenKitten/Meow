import Foundation
import HTTP
import Vapor
import Meow

public typealias PermissionCheck = ((Request) throws -> (Bool))

fileprivate var permissionChecker: PermissionCheck = { _ in
    return false
}

extension Meow {
    public static func permissionCheck(_ checker: @escaping PermissionCheck) {
        permissionChecker = checker
    }
    
    public func checkPermissions(for request: Request) throws -> Bool {
        return try permissionChecker(request)
    }
}
