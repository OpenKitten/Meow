import Cheetah
import BSON
import Meow

extension ObjectId {
    public init?(_ jsonValue: Cheetah.Value?) {
        guard let string = String(jsonValue), let id = try? ObjectId(string) else {
            return nil
        }
        
        self = id
    }
}

extension File {
    public init?(_ jsonValue: Cheetah.Value?) {
        guard let string = String(jsonValue), let id = try? ObjectId(string) else {
            return nil
        }
        
        self.id = id
    }
}
