import HTTP
import Cheetah
import Meow
import Vapor
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
    public static func integrateAuthentication(with droplet: Droplet, sessions: SessionsProtocol = MongoSessions(in: Meow.database["_sessions"])) {
        droplet.middleware = [
            SessionsMiddleware(sessions),
            ContextAwarenessMiddleware(),
            DateMiddleware(),
            FileMiddleware(publicDir: droplet.workDir + "Public/"),
        ]
    }
}
