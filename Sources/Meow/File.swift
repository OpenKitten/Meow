import MongoKitten
import Foundation

public struct File {
    public let id: ObjectId
    
    public init() {
        self.id = ObjectId()
    }
    
    public init?(_ primitive: Primitive?) throws {
        guard let id = ObjectId(primitive) else {
            return nil
        }
        
        self.id = id
    }
}
