import Puss
import Foundation

final class User : Model {
    var id = ObjectId()
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    var preferences: Reference<Preferences, Cascade>?
    
    init(email: String) {
        self.email = email
        self.registrationDate = Date()
        let preferences = Preferences()
        self.preferences = Reference(preferences)
    }
}

final class Preferences : Model {
    var id = ObjectId()
    
    var likesCheese: Bool = false
}
