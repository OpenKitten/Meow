import HTTP
import Cheetah
@_exported import Meow
@_exported import Vapor
@_exported import BSON
@_exported import MongoKitten
import Sessions
import ExtendedJSON

extension Request {
    public var jsonObject: JSONObject? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? JSONObject(from: bytes)
    }
    
    public var document: Document? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        do {
            return try Document(extendedJSON: bytes)
        } catch {
            return nil
        }
    }
}

public protocol APIModel : Model, ResponseRepresentable {
    var publicProjection: Projection { get }
}

extension APIModel {
    public func makeResponse() throws -> Response {
        return try self.serialize().redacting(publicProjection).makeResponse()
    }
}

extension Document {
    public func redacting(_ projection: Projection) -> Document {
        var doc: Document = [
            "_id": self["_id"]
        ]
        
        let projection = projection.makeDocument()
        
        for (key, value) in projection {
            if Bool(value) == true {
                doc[key] = self[key]
            } else {
                doc[key] = nil
            }
        }
        
        return doc
    }
}

extension Document : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.makeExtendedJSON().serialize()))
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
