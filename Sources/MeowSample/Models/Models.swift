import BCrypt
import MeowVapor
import Foundation

enum Gender : ConcreteSingleValueSerializable {
    case male, female
    
    func serialize() -> Primitive {
        return self == .male ? "male" : "female"
    }
    
    init?(_ primitive: Primitive?) {
        guard let string = String(primitive) else {
            return nil
        }
        
        switch string {
        case "male":
            self = .male
        case "female":
            self = .female
        default:
             return nil
        }
    }
}

struct Profile : ConcreteSerializable {
    var name: String
    var age: Int
    var picture: File?
    
    func serialize() -> Document {
        return [
            "name": name,
            "age": age,
            "picture": picture
        ]
    }
    
    init?(document source: Document) throws {
        guard let name = String(source["name"]), let age = Int(source["age"]) else {
            return nil
        }
        
        self.name = name
        self.age = age
        self.picture = try File(source["file"])
    }
}

final class User: ConcreteModel, Authenticatable, APIModel {
    public let publicProjection: Projection = ["username", "email", "gender", "profile"]
    
    var _id = ObjectId()
    var username: String
    var email: String
    var gender: Gender? = nil
    var profile: Profile?
    var password: Data
    
    static func authenticate(username: String, password: String) throws -> User? {
        guard let user = try User.findOne("username" == username) else {
            return nil
        }
        
        guard try BCrypt.Hash.verify(message: password, matches: user.password) else {
            return nil
        }
        
        Meow.currentUser = user
        
        return user
    }
    
    init(username: String, password: String, email: String, gender: Gender? = nil, profile: Profile? = nil) throws {
        self.username = username
        self.email = email
        self.password = Data(try BCrypt.Hash.make(message: password))
        self.gender = gender
        self.profile = profile
    }
    
    static var meowCollection = Meow.database["users"]
    
    func serialize() -> Document {
        return [
            "username": username,
            "email": email,
            "gender": gender,
            "password": password,
            "profile": profile?.serialize()
        ]
    }
    
    init(document source: Document) throws {
        self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")

        self.username = try Meow.Helpers.requireValue(String(source["username"]), keyForError: "username")  /* String */ 
        self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
        self.gender = Gender(source["gender"])  /* Gender? */
        self.profile = try Profile(source["profile"])  /* Profile? */
        self.password = try Meow.Helpers.requireValue(Data(source["password"]), keyForError: "password")  /* Data */ 

        Meow.pool.pool(self)
    }
}
