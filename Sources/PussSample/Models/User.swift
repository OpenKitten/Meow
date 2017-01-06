import Puss
import Foundation

final class User : Model {
    var id = ObjectId()
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    var preferences: Reference<Preferences>?
    
    init(email: String) {
        self.email = email
        self.registrationDate = Date()
    }
}

final class Preferences : Model {
    var id = ObjectId()
    
    var likesCheese: Bool = false
}
