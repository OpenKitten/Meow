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
