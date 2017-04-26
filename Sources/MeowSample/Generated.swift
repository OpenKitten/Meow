// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow


extension Breed {

	

	func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.name, as: "name")
		document.pack(self.country, as: "country")
		document.pack(self.origin, as: "origin")
		document.pack(self.kaas, as: "kaas")
		return document
	}
	
	
	static let collection: MongoKitten.Collection = Meow.database["breed"]
	
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
			
			default: throw Meow.Error.enumCaseNotFound(enum: "Breed.Country", name: rawValue)
		}
	}
	
	func serialize() -> BSON.Primitive {
		switch self {
					case .ethopia: return "ethopia"
					case .greece: return "greece"
					case .unitedStates: return "unitedStates"
			
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
// Models: 1
//   Breed
// Serializables: 3
//   Breed, Breed.Country, Breed.Origin
// Tuples: 1