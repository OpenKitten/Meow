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
//    var picture: File?
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

    
    

// sourcery:inline:auto:User.Meow
		required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.username = try document.unpack("username")
		self.email = try document.unpack("email")
		self.gender = try? document.unpack("gender")
		self.profile = try? document.unpack("profile")
		self.password = try document.unpack("password")
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
