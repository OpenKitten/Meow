import Meow
import Foundation

final class User: Model {
    var _id = ObjectId()
    var email: String
    var name: String
    var genders: [Gender]
    var favoriteNumbers: [Int] = []
    var address: Address?
    
    init(email: String, name: String, gender: Gender) {
        self.email = email
        self.name = name
        self.genders = [gender]
    }
    
    // sourcery:inline:User.Meow
    init(meowDocument source: Document) throws {      
        self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")  /* ObjectId */ 
        self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
        self.name = try Meow.Helpers.requireValue(String(source["name"]), keyForError: "name")  /* String */ 
        self.genders = try Meow.Helpers.requireValue(meowReinstantiateGenderArray(from: source["genders"]), keyForError: "genders")  /* [Gender] */ 
        self.favoriteNumbers = try Meow.Helpers.requireValue(meowReinstantiateIntArray(from: source["favoriteNumbers"]), keyForError: "favoriteNumbers")  /* [Int] */ 
        self.address = try Address(meowValue: source["address"])  /* Address? */ 
    }
    // sourcery:end
}

enum Gender {
    case male, female, undecided
}

struct Address {
    var streetName: String
    
    init(streetName: String) {
        self.streetName = streetName
    }
}
