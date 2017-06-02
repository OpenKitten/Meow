import Meow
import Foundation

public protocol CatLike : BaseModel {
    var breed: Breed { get }
}

public enum Numbers : Int {
    case one = 1
    case two = 2
    case three = 3
}

public class Tiger : Model, CatLike {
    public var breed: Breed
    public var sameBreed: Reference<Breed>
    public var singleBreeds: [Breed]
    public var sameSingleBreeds: [Reference<Breed>]
    
    public init(breed: Breed) {
        self.breed = breed
        self.sameBreed = Reference(to: breed)
        self.singleBreeds = [breed]
        self.sameSingleBreeds = [Reference(to: breed)]
    }

// sourcery:inline:auto:Tiger.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Tiger.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.breed = try document.unpack(Key.breed.keyString)
		self.sameBreed = try document.unpack(Key.sameBreed.keyString)
		self.singleBreeds = try document.unpack(Key.singleBreeds.keyString)
		self.sameSingleBreeds = try document.unpack(Key.sameSingleBreeds.keyString)
        	}

	public required init(newFrom source: BSON.Primitive) throws {
		do {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Tiger.self, source: source, expectedPrimitive: BSON.Document.self)
			}
			
			self.sameSingleBreeds = (try document.unpack(Key.sameSingleBreeds.keyString)) 
			self.singleBreeds = (try document.unpack(Key.singleBreeds.keyString)) 
			self.sameBreed = (try document.unpack(Key.sameBreed.keyString)) 
			self.breed = (try document.unpack(Key.breed.keyString)) 
			try self.save()
		} catch {
			
			Meow.pool.free(self._id)
			throw error
		}
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

public class CatReferencing : Model {
    public var cat: CatLike
    
    public init(cat: CatLike) {
        self.cat = cat
    }

// sourcery:inline:auto:CatReferencing.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: CatReferencing.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.cat = try document.unpack(Key.cat.keyString)
        	}

	public required init(newFrom source: BSON.Primitive) throws {
		do {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: CatReferencing.self, source: source, expectedPrimitive: BSON.Document.self)
			}
			
			self.cat = (try document.unpack(Key.cat.keyString)) 
			try self.save()
		} catch {
			
			Meow.pool.free(self._id)
			throw error
		}
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

public class Breed : Model, ExpressibleByStringLiteral {
    public enum Country : String {
        case ethopia, greece, unitedStates, brazil
    }
    
    public enum Origin {
        case natural, mutation, crossbreed, hybrid, hybridCrossbreed
    }
    
    public struct Thing {
        public var henk: String
        public var fred: Int
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(name: value)
    }
    
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(name: value)
    }
    
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(name: value)
    }
    
    public var name: String
    public var country: Country?
    public var origin: Origin?
    public var kaas: (String,String,String)
    public var geval: Thing?
    
    public init(name: String) {
        self.name = name
        self.kaas = (name, name, name)
    }
    
    public func purr() {
        print("Purr.")
    }

// sourcery:inline:auto:Breed.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
		self.country = try document.unpack(Key.country.keyString)
		self.origin = try document.unpack(Key.origin.keyString)
		self.kaas = try document.unpack(Key.kaas.keyString)
		self.geval = try document.unpack(Key.geval.keyString)
        	}

	public required init(newFrom source: BSON.Primitive) throws {
		do {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Breed.self, source: source, expectedPrimitive: BSON.Document.self)
			}
			
			self.geval = (try? document.unpack(Key.geval.keyString)) 
			self.kaas = (try document.unpack(Key.kaas.keyString)) 
			self.origin = (try? document.unpack(Key.origin.keyString)) 
			self.country = (try? document.unpack(Key.country.keyString)) 
			self.name = (try document.unpack(Key.name.keyString)) 
			try self.save()
		} catch {
			
			Meow.pool.free(self._id)
			throw error
		}
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

enum SocialMedia {
    case facebook(name: String)
    case twitter(handle: String)
    case reddit(username: String, activeSubreddits: [String])
    case none
}

class Cat : Model, CatLike {
    var name: String
    var breed: Breed
    var social: SocialMedia?
    var bestFriend: Reference<Cat>?
    var family: [Cat]
    var favouriteNumber: Numbers?
    
    init(name: String, breed: Breed, bestFriend: Cat?, family: [Cat]) {
        self.name = name
        self.breed = breed
        
        if let bestFriend = bestFriend {
            self.bestFriend = Reference(to: bestFriend)
        }
        
        self.family = family
    }

// sourcery:inline:auto:Cat.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Cat.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
		self.breed = try document.unpack(Key.breed.keyString)
		self.social = try document.unpack(Key.social.keyString)
		self.bestFriend = try document.unpack(Key.bestFriend.keyString)
		self.family = try document.unpack(Key.family.keyString)
		self.favouriteNumber = try document.unpack(Key.favouriteNumber.keyString)
        	}

	public required init(newFrom source: BSON.Primitive) throws {
		do {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: Cat.self, source: source, expectedPrimitive: BSON.Document.self)
			}
			
			self.favouriteNumber = (try? document.unpack(Key.favouriteNumber.keyString)) 
			self.family = (try document.unpack(Key.family.keyString)) 
			self.bestFriend = (try? document.unpack(Key.bestFriend.keyString)) 
			self.social = (try? document.unpack(Key.social.keyString)) 
			self.breed = (try document.unpack(Key.breed.keyString)) 
			self.name = (try document.unpack(Key.name.keyString)) 
			try self.save()
		} catch {
			
			Meow.pool.free(self._id)
			throw error
		}
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

