import Meow
import MeowVapor
import Foundation

enum Gender {
    case male, female
}

struct Profile {
    var name: String
    var age: Int
}

final class User: Model {
    // sourcery: public, unique
    var username: String
    
    // sourcery: public, unique
    var email: String
    
    // sourcery: public
    var gender: Gender
    
    // sourcery: public
    var profile: Profile
    
    // sourcery:inline:User.Meow
      init(meowDocument source: Document) throws {
          self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")
        
          self.username = try Meow.Helpers.requireValue(String(source["username"]), keyForError: "username")  /* String */ 
          self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
          self.gender = try Meow.Helpers.requireValue(Gender(meowValue: source["gender"]), keyForError: "gender")  /* Gender */ 
          self.profile = try Meow.Helpers.requireValue(Profile(meowValue: source["profile"]), keyForError: "profile")  /* Profile */ 

        Meow.pool.pool(self)
      }
      
        var _id = ObjectId()
    // sourcery:end
}
