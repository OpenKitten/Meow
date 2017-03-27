import HTTP
import Cheetah

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
