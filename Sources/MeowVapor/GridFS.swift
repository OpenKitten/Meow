import Meow
import Foundation
import MongoKitten
import HTTP
import Vapor

extension File : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        guard let file = try GridFS.default.readFile(from: specification) else {
            throw Abort.notFound
        }
        
        let headers: [HeaderKey: String] = ["Content-Type": Limits.mimeType]
        
        return Response(status: .ok, headers: headers) { stream in
            for chunk in file {
                try stream.write(chunk)
                try stream.flush(timingOut: 5)
            }
            
            try stream.close()
        }
    }
}

extension Optional where Wrapped : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        guard let wrapped = self else {
            throw Abort.notFound
        }
        
        return try wrapped.makeResponse()
    }
}
