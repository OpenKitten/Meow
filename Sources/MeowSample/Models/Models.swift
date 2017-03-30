import BCrypt
import MeowVapor
import Foundation

enum Gender {
    case male, female
}

struct Profile {
    // sourcery: public
    var name: String
    
    // sourcery: public
    var age: Int
    
    // sourcery: public
    var picture: File?
}

// sourcery: user
final class User: Model {
    // sourcery: public, unique
    var username: String
    
    // sourcery: public, unique
    var email: String
    
    // sourcery: public
    var gender: Gender? = nil
    
    // sourcery: public
    var profile: Profile?
    
    var password: Data
    
    // sourcery: public, method = POST
    static func authenticate(username: String, password: String) throws -> User? {
        guard let user = try User.findOne({ user in
            return user.username == username
        }) else {
            return nil
        }
        
        guard try BCrypt.Hash.verify(message: user.password, matches: password) else {
            return nil
        }
        
        Meow.currentUser = user
        
        return user
    }
    
    init?(username: String, password: String, email: String, gender: Gender? = nil, profile: Profile? = nil) throws {
        self.username = username
        self.email = email
        self.password = Data(try BCrypt.Hash.make(message: password))
        self.gender = gender
        self.profile = profile
    }
    
    // sourcery:inline:User.Meow
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
