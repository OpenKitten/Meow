import BCrypt
import MeowVapor
import Foundation

enum Gender {
    case male, female
}

struct Profile {
    var name: String
    var age: Int
    
    // sourcery: name = "profilePicture"
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
      init(document source: Document) throws {
          self._id = try Meow.Helpers.requireValue(ObjectId(source[Key._id.keyString]), keyForError: "_id")
        
          self.username = try Meow.Helpers.requireValue(String(source[Key.username.keyString]), keyForError: "username")  /* String */ 
          self.email = try Meow.Helpers.requireValue(String(source[Key.email.keyString]), keyForError: "email")  /* String */ 
          self.gender = try Gender(meowValue: source[Key.gender.keyString])  /* Gender? */ 
          self.profile = try Profile(meowValue: source[Key.profile.keyString])  /* Profile? */ 
          self.password = try Meow.Helpers.requireValue(Data(source[Key.password.keyString]), keyForError: "password")  /* Data */ 

        Meow.pool.pool(self)
      }
      
        var _id = ObjectId()
// sourcery:end
}
