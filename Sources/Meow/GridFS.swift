import Cheetah
import MongoKitten
import Foundation

extension Meow {
    /// The default Meow GridFS instance.
    public static var fs: GridFS = {
        return try! Meow.database.makeGridFS()
    }()
}

public struct FileReference : Codable, Referencing {
    public let reference: ObjectId
    
    public init(id: ObjectId) {
        self.reference = id
    }
    
    public init(from decoder: Decoder) throws {
        reference = try ObjectId(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try reference.encode(to: encoder)
    }
    
    public func resolve() throws -> GridFS.File {
        guard let file = try Meow.fs.findOne(byID: reference) else {
            throw Meow.Error.brokenFileReference(reference)
        }
        
        return file
    }
}
