// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: Meow.ejs
// MARK: MeowCore.ejs


// MARK: - General Information
// Supported Primitives: ObjectId, String, Int, Int32, Bool, Document, Double, Data, Binary, Date, RegularExpression
// Sourcery Types: class Breed, enum Breed.Country, enum Breed.Origin, struct Breed.Thing, class Cat, class CatReferencing, class Tiger
import Foundation
import Meow
import ExtendedJSON


// MARK: Protocols.ejs




// MARK: - 🐈 for Breed
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension Breed : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.name, as: Key.name.keyString)
		document.pack(self.country, as: Key.country.keyString)
		document.pack(self.origin, as: Key.origin.keyString)
		document.pack(self.kaas, as: Key.kaas.keyString)
		document.pack(self.geval, as: Key.geval.keyString)
		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.name.keyString) {
			_ = (try document.unpack(Key.name.keyString)) as String
		}
		if keys.contains(Key.country.keyString) {
			_ = (try document.unpack(Key.country.keyString)) as Country?
		}
		if keys.contains(Key.origin.keyString) {
			_ = (try document.unpack(Key.origin.keyString)) as Origin?
		}
		if keys.contains(Key.kaas.keyString) {
			_ = (try document.unpack(Key.kaas.keyString)) as (String,String,String)
		}
		if keys.contains(Key.geval.keyString) {
			_ = (try document.unpack(Key.geval.keyString)) as Thing?
		}
	}

	public func update(with document: Document) throws {
		try Breed.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.name.keyString:
				self.name = try document.unpack(Key.name.keyString)
			case Key.country.keyString:
				self.country = try document.unpack(Key.country.keyString)
			case Key.origin.keyString:
				self.origin = try document.unpack(Key.origin.keyString)
			case Key.kaas.keyString:
				self.kaas = try document.unpack(Key.kaas.keyString)
			case Key.geval.keyString:
				self.geval = try document.unpack(Key.geval.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["breeds"]
	

	// MARK: ModelResolvingFunctions.ejs

	
	public static func byId(_ value: ObjectId) throws -> Breed? {
		return try Breed.findOne("_id" == value)
	}
	



	public static func byName(_ value: String) throws -> Breed? {
		return try Breed.findOne(Key.name.rawValue == value)
	}


	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case name = "name"
		case country = "country"
		case origin = "origin"
		case kaas = "kaas"
		case geval = "geval"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .name: return String.self
			case .country: return Country.self
			case .origin: return Origin.self
			case .kaas: return (String,String,String).self
			case .geval: return Thing.self
			}
		}

		public static var all: [Key] {
			return [._id, .name, .country, .origin, .kaas, .geval]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a Breed
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Breed.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var name: String?
		public var country: Country?
		public var origin: Origin?
		public var kaas: (String,String,String)?
		public var geval: Thing?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.name, as: Key.name.keyString)
			document.pack(self.country, as: Key.country.keyString)
			document.pack(self.origin, as: Key.origin.keyString)
			document.pack(self.kaas, as: Key.kaas.keyString)
			document.pack(self.geval, as: Key.geval.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.name.keyString:
					self.name = try document.unpack(Key.name.keyString)
				case Key.country.keyString:
					self.country = try document.unpack(Key.country.keyString)
				case Key.origin.keyString:
					self.origin = try document.unpack(Key.origin.keyString)
				case Key.kaas.keyString:
					self.kaas = try document.unpack(Key.kaas.keyString)
				case Key.geval.keyString:
					self.geval = try document.unpack(Key.geval.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Breed?) -> Query {
		
		return (lhs.keyPrefix + ".$id") == rhs?._id
		
	}

	public let keyPrefix: String
	public let isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: keyPrefix + Key._id.keyString)
	}
	

	
		 /// name: String
		 public var name: VirtualString { return VirtualString(name: keyPrefix + Key.name.keyString) } 
		 /// country: Country?
		 public var country: Country.VirtualInstance { return Country.VirtualInstance(keyPrefix: keyPrefix + Key.country.keyString) } 
		 /// origin: Origin?
		 public var origin: Origin.VirtualInstance { return Origin.VirtualInstance(keyPrefix: keyPrefix + Key.origin.keyString) } 
		 /// kaas: (String,String,String)
		 
		 /// geval: Thing?
		 public var geval: Thing.VirtualInstance { return Thing.VirtualInstance(keyPrefix: keyPrefix + Key.geval.keyString) } 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension Breed : CustomStringConvertible {
	public var description: String {
	
		return "Breed<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}





// MARK: - 🐈 for Cat
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension Cat : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.name, as: Key.name.keyString)
		document.pack(self.breed, as: Key.breed.keyString)
		document.pack(self.bestFriend, as: Key.bestFriend.keyString)
		document.pack(self.family, as: Key.family.keyString)
		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.name.keyString) {
			_ = (try document.unpack(Key.name.keyString)) as String
		}
		if keys.contains(Key.breed.keyString) {
			_ = (try document.unpack(Key.breed.keyString)) as Breed
		}
		if keys.contains(Key.bestFriend.keyString) {
			_ = (try document.unpack(Key.bestFriend.keyString)) as Reference<Cat>?
		}
		if keys.contains(Key.family.keyString) {
			_ = (try document.unpack(Key.family.keyString)) as [Cat]
		}
	}

	public func update(with document: Document) throws {
		try Cat.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.name.keyString:
				self.name = try document.unpack(Key.name.keyString)
			case Key.breed.keyString:
				self.breed = try document.unpack(Key.breed.keyString)
			case Key.bestFriend.keyString:
				self.bestFriend = try document.unpack(Key.bestFriend.keyString)
			case Key.family.keyString:
				self.family = try document.unpack(Key.family.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["cats"]
	

	// MARK: ModelResolvingFunctions.ejs

	
	public static func byId(_ value: ObjectId) throws -> Cat? {
		return try Cat.findOne("_id" == value)
	}
	



	public static func byName(_ value: String) throws -> Cat? {
		return try Cat.findOne(Key.name.rawValue == value)
	}


	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case name = "name"
		case breed = "breed"
		case bestFriend = "best_friend"
		case family = "family"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .name: return String.self
			case .breed: return Breed.self
			case .bestFriend: return Reference<Cat>.self
			case .family: return [Cat].self
			}
		}

		public static var all: [Key] {
			return [._id, .name, .breed, .bestFriend, .family]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a Cat
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Cat.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var name: String?
		public var breed: Breed?
		public var bestFriend: Reference<Cat>?
		public var family: [Cat]?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.name, as: Key.name.keyString)
			document.pack(self.breed, as: Key.breed.keyString)
			document.pack(self.bestFriend, as: Key.bestFriend.keyString)
			document.pack(self.family, as: Key.family.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.name.keyString:
					self.name = try document.unpack(Key.name.keyString)
				case Key.breed.keyString:
					self.breed = try document.unpack(Key.breed.keyString)
				case Key.bestFriend.keyString:
					self.bestFriend = try document.unpack(Key.bestFriend.keyString)
				case Key.family.keyString:
					self.family = try document.unpack(Key.family.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Cat?) -> Query {
		
		return (lhs.keyPrefix + ".$id") == rhs?._id
		
	}

	public let keyPrefix: String
	var isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: keyPrefix + Key._id.keyString)
	}
	

	
		 /// name: String
		 public var name: VirtualString { return VirtualString(name: keyPrefix + Key.name.keyString) } 
		 /// breed: Breed
		 public var breed: Breed.VirtualInstance { return Breed.VirtualInstance(keyPrefix: keyPrefix + Key.breed.keyString, isReference: true) }
		 /// bestFriend: Reference<Cat>?
		 
		 /// family: [Cat]
		 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension Cat : CustomStringConvertible {
	public var description: String {
	
		return "Cat<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}





// MARK: - 🐈 for CatReferencing
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension CatReferencing : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.cat, as: Key.cat.keyString)
		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.cat.keyString) {
			_ = (try document.unpack(Key.cat.keyString)) as CatLike
		}
	}

	public func update(with document: Document) throws {
		try CatReferencing.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.cat.keyString:
				self.cat = try document.unpack(Key.cat.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["cat_referencings"]
	

	// MARK: ModelResolvingFunctions.ejs

	
	public static func byId(_ value: ObjectId) throws -> CatReferencing? {
		return try CatReferencing.findOne("_id" == value)
	}
	




	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case cat = "cat"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .cat: return CatLike.self
			}
		}

		public static var all: [Key] {
			return [._id, .cat]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a CatReferencing
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: CatReferencing.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var cat: CatLike?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.cat, as: Key.cat.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.cat.keyString:
					self.cat = try document.unpack(Key.cat.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: CatReferencing?) -> Query {
		
		return (lhs.keyPrefix + ".$id") == rhs?._id
		
	}

	public let keyPrefix: String
	public let isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: keyPrefix + Key._id.keyString)
	}
	

	
		 /// cat: CatLike
		 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension CatReferencing : CustomStringConvertible {
	public var description: String {
	
		return "CatReferencing<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}





// MARK: - 🐈 for Tiger
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension Tiger : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.breed, as: Key.breed.keyString)
		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.breed.keyString) {
			_ = (try document.unpack(Key.breed.keyString)) as Breed
		}
	}

	public func update(with document: Document) throws {
		try Tiger.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.breed.keyString:
				self.breed = try document.unpack(Key.breed.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["tigers"]
	

	// MARK: ModelResolvingFunctions.ejs

	
	public static func byId(_ value: ObjectId) throws -> Tiger? {
		return try Tiger.findOne("_id" == value)
	}
	




	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case breed = "breed"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .breed: return Breed.self
			}
		}

		public static var all: [Key] {
			return [._id, .breed]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a Tiger
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Tiger.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var breed: Breed?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.breed, as: Key.breed.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.breed.keyString:
					self.breed = try document.unpack(Key.breed.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Tiger?) -> Query {
		
		return (lhs.keyPrefix + ".$id") == rhs?._id
		
	}

	public let keyPrefix: String
	public let isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: keyPrefix + Key._id.keyString)
	}
	

	
		 /// breed: Breed
		 public var breed: Breed.VirtualInstance { return Breed.VirtualInstance(keyPrefix: keyPrefix + Key.breed.keyString, isReference: true) }

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension Tiger : CustomStringConvertible {
	public var description: String {
	
		return "Tiger<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}





// MARK: - 🐈 for Breed.Country
// MARK: Serializable.ejs
// MARK: SerializableEnum.ejs
extension Breed.Country : Serializable {
	public init(restoring source: BSON.Primitive) throws {
		guard let value = String(source), let me = Breed.Country(rawValue: value) else {
			throw Meow.Error.cannotDeserialize(type: Breed.Country.self, source: source, expectedPrimitive: String.self)
		}

		self = me
	}

	public func serialize() -> Primitive {
		return self.rawValue
	}

	// MARK: VirtualInstanceEnum.ejs
public struct VirtualInstance {
	/// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Breed.Country?) -> Query {
		return lhs.keyPrefix == rhs?.serialize()
	}

	public let keyPrefix: String

	public init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
}

}




// MARK: - 🐈 for Breed.Origin
// MARK: Serializable.ejs
// MARK: SerializableEnum.ejs
extension Breed.Origin : Serializable {
	public init(restoring source: BSON.Primitive) throws {
		guard let rawValue = String(source) ?? String(Document(source)?[0]) else {
			throw Meow.Error.cannotDeserialize(type: Breed.Origin.self, source: source, expectedPrimitive: String.self)
		}

		switch rawValue {
			case "natural":
							self = .natural
						case "mutation":
							self = .mutation
						case "crossbreed":
							self = .crossbreed
						case "hybrid":
							self = .hybrid
						case "hybridCrossbreed":
							self = .hybridCrossbreed
					default: throw Meow.Error.enumCaseNotFound(enum: "Breed.Origin", name: rawValue)
		}
	}

	public func serialize() -> BSON.Primitive {
		switch self {
		case .natural: return "natural"
		case .mutation: return "mutation"
		case .crossbreed: return "crossbreed"
		case .hybrid: return "hybrid"
		case .hybridCrossbreed: return "hybridCrossbreed"
		}
	}

	// MARK: VirtualInstanceEnum.ejs
public struct VirtualInstance {
	/// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Breed.Origin?) -> Query {
		return lhs.keyPrefix == rhs?.serialize()
	}

	public let keyPrefix: String

	public init(keyPrefix: String = "") {
		self.keyPrefix = keyPrefix
	}
}

}




// MARK: - 🐈 for Breed.Thing
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension Breed.Thing : SerializableToDocument {
	
	
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.Thing.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.henk = try document.unpack(Key.henk.keyString)
		self.fred = try document.unpack(Key.fred.keyString)
	}

	public init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.Thing.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.fred = (try document.unpack(Key.fred.keyString)) 
		self.henk = (try document.unpack(Key.henk.keyString)) 
	}

	

	public func serialize() -> Document {
		var document: Document = [:]
		
		document.pack(self.henk, as: Key.henk.keyString)
		document.pack(self.fred, as: Key.fred.keyString)
		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.henk.keyString) {
			_ = (try document.unpack(Key.henk.keyString)) as String
		}
		if keys.contains(Key.fred.keyString) {
			_ = (try document.unpack(Key.fred.keyString)) as Int
		}
	}

	public mutating func update(with document: Document) throws {
		try Breed.Thing.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.henk.keyString:
				self.henk = try document.unpack(Key.henk.keyString)
			case Key.fred.keyString:
				self.fred = try document.unpack(Key.fred.keyString)
			default: break
			}
		}
	}

	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		
		case henk = "henk"
		case fred = "fred"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			
			case .henk: return String.self
			case .fred: return Int.self
			}
		}

		public static var all: [Key] {
			return [.henk, .fred]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a Breed.Thing
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Breed.Thing.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var henk: String?
		public var fred: Int?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.henk, as: Key.henk.keyString)
			document.pack(self.fred, as: Key.fred.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.henk.keyString:
					self.henk = try document.unpack(Key.henk.keyString)
				case Key.fred.keyString:
					self.fred = try document.unpack(Key.fred.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: Breed.Thing?) -> Query {
		
		return lhs.keyPrefix == rhs?.serialize()
		
	}

	public let keyPrefix: String
	public let isReference: Bool

	

	
		 /// henk: String
		 public var henk: VirtualString { return VirtualString(name: keyPrefix + Key.henk.keyString) } 
		 /// fred: Int
		 public var fred: VirtualNumber { return VirtualNumber(name: keyPrefix + Key.fred.keyString) } 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = false
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension Breed.Thing : CustomStringConvertible {
	public var description: String {
	
		return "Breed.Thing<" + (self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString() + ">"
	
	}
}





// MARK: - 🐈 for CatLike
// MARK: Serializable.ejs
// MARK: SerializableProtocol.ejs
extension Document {
	func unpack(_ key: String) throws -> CatLike {
		guard let document = self[key] as? Document, let ref = DBRef(document, inDatabase: Meow.database) else {
			throw Meow.Error.missingOrInvalidValue(key: key)
		}
		
		guard let instance = try ref.resolveModel() as? CatLike else {
			throw Meow.Error.missingOrInvalidValue(key: key)
		}
		
		return instance
	}
}



// MARK: Tuple.ejs
extension Document {
	public mutating func pack(_ tuple: (String,String,String)?, as key: String) {
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

	public func unpack(_ key: String) throws -> (String,String,String) {
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

		

fileprivate let meows: [Any.Type] = [Breed.self, Cat.self, CatReferencing.self, Tiger.self, Breed.Country.self, Breed.Origin.self, Breed.Thing.self, CatLike.self]

extension Meow {
	static func `init`(_ connectionString: String) throws {
		try Meow.init(connectionString, meows)
	}
	
	static func `init`(_ db: MongoKitten.Database) {
		Meow.init(db, meows)
	}
}

// 🐈 Statistics
// Models: 4
//   Breed, Cat, CatReferencing, Tiger
// Serializables: 8
//   Breed, Cat, CatReferencing, Tiger, Breed.Country, Breed.Origin, Breed.Thing, CatLike
// Model protocols: 0
//   
// Tuples: 1
