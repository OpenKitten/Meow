import Meow
import Foundation

final class House : Model {
    var id = ObjectId()
    
    var owner: Reference<User, Deny>?
}

final class User : Model {
    var id = ObjectId()
    
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    var preferences = Preferences()
    var pet: Reference<Dog, Cascade>
    var boss: Reference<User, Ignore>?
    
    init(email: String) throws {
        self.email = email
        self.registrationDate = Date()
        let pet = Dog()
        try pet.save()
        self.pet = Reference(pet)
    }
}

final class Preferences : Embeddable {
    var likesCheese: Bool = false
}

final class Dog : Model {
    var id = ObjectId()
    var name: String = "Fluffy"
    
    var preferences: Preferences?
}

final class Flat : Model {
    var id = ObjectId()
    
    var owners: [Reference<User, Cascade>] = []
}
