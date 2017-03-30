import HTTP
import Cheetah
@_exported import Meow
@_exported import Vapor
@_exported import BSON
import Sessions

extension Request {
    public var jsonObject: JSONObject? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? JSONObject(from: bytes)
    }
}

extension JSONObject : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}

extension JSONArray : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}

extension Meow {
    public static func integrateAuthentication(with droplet: Droplet, sessionManager: SessionsProtocol = MongoSessions(in: Meow.database["_sessions"])) {
        AuthenticationMiddleware.default.enabled = true
        AuthorizationMiddleware.default.enabled = true
        
        droplet.middleware = [
            SessionsMiddleware(sessionManager),
            ContextAwarenessMiddleware(),
            DateMiddleware(),
            FileMiddleware(publicDir: droplet.workDir + "Public/")
        ]
    }
}
