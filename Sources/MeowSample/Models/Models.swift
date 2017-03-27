import Meow
import Foundation

enum Gender {
    case male, female, undecided
}

struct Address {
    var streetName: String
    
    init(streetName: String) {
        self.streetName = streetName
    }
}

final class User: Model {
    var email: String
    
    // sourcery: public
    var name: String
    
    var genders: [Gender]
    var favoriteNumbers: [Int] = []
    var address: Address?
    
    // sourcery: permissions = "anonymous"
    init(email: String, name: String) {
        self.email = email
        self.name = name
        self.genders = []
    }
    
    // sourcery:inline:User.Meow
      init(meowDocument source: Document) throws {
          self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")
        
          self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
          self.name = try Meow.Helpers.requireValue(String(source["name"]), keyForError: "name")  /* String */ 
          self.genders = try Meow.Helpers.requireValue(meowReinstantiateGenderArray(from: source["genders"]), keyForError: "genders")  /* [Gender] */ 
          self.favoriteNumbers = try Meow.Helpers.requireValue(meowReinstantiateIntArray(from: source["favoriteNumbers"]), keyForError: "favoriteNumbers")  /* [Int] */ 
          self.address = try Address(meowValue: source["address"])  /* Address? */ 

        Meow.pool.pool(self)
      }
      
        var _id = ObjectId()
    // sourcery:end
}
