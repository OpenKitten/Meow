// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow
import ExtendedJSON
import MeowVapor
import Vapor
import Cheetah
import HTTP


extension User : SerializableToDocument {

	

	func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.username, as: "username")
		document.pack(self.email, as: "email")
		document.pack(self.gender, as: "gender")
		document.pack(self.profile, as: "profile")
		document.pack(self.password, as: "password")
		return document
	}

	
	static let collection: MongoKitten.Collection = Meow.database["user"]

	func handleDeinit() {
		do {
			try self.save()

		} catch {
			print("error while saving Meow object in deinit: \(error)")
			assertionFailure()
		}
	}
	

	enum Key : String, KeyRepresentable {	case _id
	
	case username
	case email
	case gender
	case profile
	case password

	var keyString: String { return self.rawValue }
}

	
struct VirtualInstance {
	var keyPrefix: String

	
		 /// username: String
		  var username: VirtualString { return VirtualString(name: keyPrefix + Key.username.keyString) } 
		 /// email: String
		  var email: VirtualString { return VirtualString(name: keyPrefix + Key.email.keyString) } 
		 /// gender: Gender?
		  var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: keyPrefix + Key.gender.keyString) } 
		 /// profile: Profile?
		  var profile: Profile.VirtualInstance { return Profile.VirtualInstance(keyPrefix: keyPrefix + Key.profile.keyString) } 
		 /// password: Data
		  var password: VirtualData { return VirtualData(name: keyPrefix + Key.password.keyString) } 

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
} // end VirtualInstance
	
	public static func find(_ amount: Int? = nil, _ closure: ((VirtualInstance)->(Query))) throws -> CollectionSlice<User> {
		return try find(closure(VirtualInstance()))
	}

	public static func findOne(_ closure: ((VirtualInstance)->(Query))) throws -> User? {
		return try findOne(closure(VirtualInstance()))
	}


}

extension User : CustomStringConvertible {
	var description: String {
		return (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString()
	}
}


	extension User : Authenticatable {
		public static func resolve(byId identifier: ObjectId) throws -> User? {
				guard let document = try User.meowCollection.findOne("_id" == identifier) else {
						return nil
				}

				return try Meow.pool.instantiateIfNeeded(type: User.self, document: document)
		}
	}
extension User {
    public convenience init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
extension User {
  public func makeJSONObject() -> JSONObject {
      let object: JSONObject = [
          "id": self._id.hexString
      ]


      return object
  }
}



extension Gender : Serializable {
	init(restoring source: BSON.Primitive) throws {
		guard let rawValue = String(source) else {
				throw Meow.Error.cannotDeserialize(type: Gender.self, source: source, expectedPrimitive: String.self)
		}

		switch rawValue {
			 case "male": self = .male
			 case "female": self = .female
			
			default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
		}
	}
	
	func serialize() -> BSON.Primitive {
		switch self {
					case .male: return "male"
					case .female: return "female"
			
		}
	}
	
	
struct VirtualInstance {
	/// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
	static func ==(lhs: VirtualInstance, rhs: Gender?) -> Query {
		return lhs.keyPrefix == rhs?.serialize()
	}

	var keyPrefix: String

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
}
}


extension Gender {
    public init(jsonValue: Cheetah.Value?) throws {
    
        let rawValue = try Meow.Helpers.requireValue(String(jsonValue), keyForError: "enum Gender")
        switch rawValue {
         case "male": self = .male
         case "female": self = .female
        
          default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
        }
    
  }
}
extension Gender {
  public func makeJSONObject() -> JSONObject {
      let object: JSONObject = [:]


      return object
  }
}



extension Profile : SerializableToDocument {
	
	
		init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Profile.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.name = try document.unpack("name")
		self.age = try document.unpack("age")
		self.picture = try? document.unpack("picture")
	}

	

	func serialize() -> Document {
		var document: Document = [:]
		
		document.pack(self.name, as: "name")
		document.pack(self.age, as: "age")
		document.pack(self.picture, as: "picture")
		return document
	}

	

	enum Key : String, KeyRepresentable {	
	
	case name
	case age
	case picture

	var keyString: String { return self.rawValue }
}

	
struct VirtualInstance {
	var keyPrefix: String

	
		 /// name: String
		  var name: VirtualString { return VirtualString(name: keyPrefix + Key.name.keyString) } 
		 /// age: Int
		  var age: VirtualNumber { return VirtualNumber(name: keyPrefix + Key.age.keyString) } 
		 /// picture: File?
		 

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
} // end VirtualInstance
	

}

extension Profile : CustomStringConvertible {
	var description: String {
		return (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString()
	}
}


extension Profile {
    public init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
extension Profile {
  public func makeJSONObject() -> JSONObject {
      let object: JSONObject = [:]


      return object
  }
}



<# Type of kind 'undefined' named 'undefined' unknown to Meow. Cannot generate Serializable implementation. ([object Sourcery.TypeName]) #>

extension File? {
    public init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
extension File? {
  public func makeJSONObject() -> JSONObject {
      let object: JSONObject = [:]


      return object
  }
}




let meows: [Any.Type] = [User.self, Gender.self, Profile.self, File?.self]

// 🐈 Statistics
// Models: 1
//   User
// Serializables: 4
//   User, Gender, Profile, File?
// Tuples: 0
