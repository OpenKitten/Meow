// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow
import ExtendedJSON


extension Breed : SerializableToDocument {

	

	func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.name, as: "name")
		document.pack(self.country, as: "country")
		document.pack(self.origin, as: "origin")
		document.pack(self.kaas, as: "kaas")
		document.pack(self.geval, as: "geval")
		return document
	}
	
	
	static let collection: MongoKitten.Collection = Meow.database["breed"]
	
	func handleDeinit() {
		do {
			try self.save()
			
		} catch {
			print("error while saving Meow object in deinit: \(error)")
			assertionFailure()
		}
	}
	
	
	enum Key : String {	case _id
	
	case name	
	case country	
	case origin	
	case kaas	
	case geval	

	var keyString: String { return self.rawValue }
}
	
struct VirtualInstance {
	var keyPrefix: String

	
		 /// name: String
		  var name: VirtualString { return VirtualString(name: keyPrefix + Key.name.keyString) } 
		 /// country: Country?
		  var country: Country.VirtualInstance { return Country.VirtualInstance(keyPrefix: keyPrefix + Key.country.keyString) } 
		 /// origin: Origin?
		  var origin: Origin.VirtualInstance { return Origin.VirtualInstance(keyPrefix: keyPrefix + Key.origin.keyString) } 
		 /// kaas: (String,String,String)
		 
		 /// geval: Thing?
		  var geval: Thing.VirtualInstance { return Thing.VirtualInstance(keyPrefix: keyPrefix + Key.geval.keyString) } 

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
} // end VirtualInstance
}

extension Breed : CustomStringConvertible {
	var description: String {
		return (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString()
	}
}

		
extension Cat : SerializableToDocument {

	

	func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.name, as: "name")
		document.pack(self.breed, as: "breed")
		document.pack(self.bestFriend, as: "bestFriend")
		document.pack(self.family, as: "family")
		return document
	}
	
	
	static let collection: MongoKitten.Collection = Meow.database["cat"]
	
	func handleDeinit() {
		do {
			try self.save()
			
		} catch {
			print("error while saving Meow object in deinit: \(error)")
			assertionFailure()
		}
	}
	
	
	enum Key : String {	case _id
	
	case name	
	case breed	
	case bestFriend	
	case family	

	var keyString: String { return self.rawValue }
}
	
struct VirtualInstance {
	var keyPrefix: String

	
		 /// name: String
		  var name: VirtualString { return VirtualString(name: keyPrefix + Key.name.keyString) } 
		 /// breed: Breed
		  var breed: Breed.VirtualInstance { return Breed.VirtualInstance(keyPrefix: keyPrefix + Key.breed.keyString) } 
		 /// bestFriend: Reference<Cat>?
		 
		 /// family: [Cat]
		 

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
} // end VirtualInstance
}

extension Cat : CustomStringConvertible {
	var description: String {
		return (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString()
	}
}

		
extension Breed.Country : Serializable {
	init(restoring source: BSON.Primitive) throws {
		guard let rawValue = String(source) else {
				throw Meow.Error.cannotDeserialize(type: Breed.Country.self, source: source, expectedPrimitive: String.self)
		}

		switch rawValue {
			 case "ethopia": self = .ethopia
			 case "greece": self = .greece
			 case "unitedStates": self = .unitedStates
			 case "brazil": self = .brazil
			
			default: throw Meow.Error.enumCaseNotFound(enum: "Breed.Country", name: rawValue)
		}
	}
	
	func serialize() -> BSON.Primitive {
		switch self {
					case .ethopia: return "ethopia"
					case .greece: return "greece"
					case .unitedStates: return "unitedStates"
					case .brazil: return "brazil"
			
		}
	}
	
	
struct VirtualInstance {
	/// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
	static func ==(lhs: VirtualInstance, rhs: Breed.Country?) -> Query {
		return lhs.keyPrefix == rhs?.serialize()
	}

	var keyPrefix: String

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
}
}

		
extension Breed.Origin : Serializable {
	init(restoring source: BSON.Primitive) throws {
		guard let rawValue = String(source) else {
				throw Meow.Error.cannotDeserialize(type: Breed.Origin.self, source: source, expectedPrimitive: String.self)
		}

		switch rawValue {
			 case "natural": self = .natural
			 case "mutation": self = .mutation
			 case "crossbreed": self = .crossbreed
			 case "hybrid": self = .hybrid
			 case "hybridCrossbreed": self = .hybridCrossbreed
			
			default: throw Meow.Error.enumCaseNotFound(enum: "Breed.Origin", name: rawValue)
		}
	}
	
	func serialize() -> BSON.Primitive {
		switch self {
					case .natural: return "natural"
					case .mutation: return "mutation"
					case .crossbreed: return "crossbreed"
					case .hybrid: return "hybrid"
					case .hybridCrossbreed: return "hybridCrossbreed"
			
		}
	}
	
	
struct VirtualInstance {
	/// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
	static func ==(lhs: VirtualInstance, rhs: Breed.Origin?) -> Query {
		return lhs.keyPrefix == rhs?.serialize()
	}

	var keyPrefix: String

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
}
}

		
extension Breed.Thing : SerializableToDocument {
	
	
		init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.Thing.self, source: source, expectedPrimitive: BSON.Document.self);
		}
		
		
		self.henk = try document.unpack("henk")
		self.fred = try document.unpack("fred")
	}
	
	

	func serialize() -> Document {
		var document: Document = [:]
		
		document.pack(self.henk, as: "henk")
		document.pack(self.fred, as: "fred")
		return document
	}
	
	
	
	enum Key : String {	
	
	case henk	
	case fred	

	var keyString: String { return self.rawValue }
}
	
struct VirtualInstance {
	var keyPrefix: String

	
		 /// henk: String
		  var henk: VirtualString { return VirtualString(name: keyPrefix + Key.henk.keyString) } 
		 /// fred: Int
		  var fred: VirtualNumber { return VirtualNumber(name: keyPrefix + Key.fred.keyString) } 

	init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
} // end VirtualInstance
}

extension Breed.Thing : CustomStringConvertible {
	var description: String {
		return (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString()
	}
}

		
extension Document {
	mutating func pack(_ tuple: (String,String,String)?, as key: String) {
		guard let tuple = tuple else {
			self[key] = nil
			return
		}
		
		var document: Document = [:]		
		document.pack(tuple.0, as: "0")		
		document.pack(tuple.1, as: "1")		
		document.pack(tuple.2, as: "2")		
		self[key] = document
	}
	
	func unpack(_ key: String) throws -> (String,String,String) {
		guard let document = Document(self[key]) else {
			throw Meow.Error.cannotDeserialize(type: Document.self, source: self[key], expectedPrimitive: Document.self)
		}

		return try (			
				 				 				 				document.unpack("0") 				, 			
				 				 				 				document.unpack("1") 				, 			
				 				 				 				document.unpack("2") 				 			
		)
	}
}
		

// 🐈 Statistics
// Models: 2
//   Breed, Cat
// Serializables: 5
//   Breed, Cat, Breed.Country, Breed.Origin, Breed.Thing
// Tuples: 1