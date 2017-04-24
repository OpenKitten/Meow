import BCrypt
import MeowVapor
import Foundation

enum Gender {
    case male, female
}

struct Profile {
    var name: String
    var age: Int
    var picture: File?
}

// sourcery: user
final class User: Model {
    var username: String
    var email: String
    var gender: Gender? = nil
    var profile: Profile?
    var password: Data
    
    // sourery: public
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

// sourcery:inline:auto:User
      init(meowDocument source: Document) throws {
          self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")
        
          self.username = try Meow.Helpers.requireValue(String(source["username"]), keyForError: "username")  /* String */ 
          self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
          self.gender = try Gender(meowValue: source["gender"])  /* Gender? */ 
          self.profile = try Profile(meowValue: source["profile"])  /* Profile? */ 
          self.password = try Meow.Helpers.requireValue(Data(source["password"]), keyForError: "password")  /* Data */ 

        Meow.pool.pool(self)
      }
      
        var _id = ObjectId()
// sourcery:end
}
