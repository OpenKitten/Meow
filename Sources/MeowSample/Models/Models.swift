import Meow
import Foundation

class Breed : Model {
    enum Country : String {
      case ethopia, greece, unitedStates, brazil
    }

    enum Origin {
      case natural, mutation, crossbreed, hybrid, hybridCrossbreed
    }
    
    struct Thing {
        var henk: String
        var fred: Int
    }

    var name: String
    var country: Country?
    var origin: Origin?
    var kaas: (String,String,String)
    var geval: Thing?
    
    init(name: String) {
      self.name = name
        self.kaas = (name, name, name)
    }

    func purr() {
        print("Purr.")
    }

// sourcery:inline:auto:Breed.Meow
	required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
		self.country = try? document.unpack(Key.country.keyString)
		self.origin = try? document.unpack(Key.origin.keyString)
		self.kaas = try document.unpack(Key.kaas.keyString)
		self.geval = try? document.unpack(Key.geval.keyString)
	}
	
	required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.geval = (try? document.unpack(Key.geval.keyString)) 
		self.kaas = (try document.unpack(Key.kaas.keyString)) 
		self.origin = (try? document.unpack(Key.origin.keyString)) 
		self.country = (try? document.unpack(Key.country.keyString)) 
		self.name = (try document.unpack(Key.name.keyString)) 
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

class Cat : Model, CatLike {
    var name: String
    var breed: Breed
    var bestFriend: Reference<Cat>?
    var family: [Cat]
    
    init(name: String, breed: Breed, bestFriend: Cat?, family: [Cat]) {
        self.name = name
        self.breed = breed
        
        if let bestFriend = bestFriend {
            self.bestFriend = Reference(to: bestFriend)
        }
        
        self.family = family
    }

// sourcery:inline:auto:Cat.Meow
	required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Cat.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
		self.breed = try document.unpack(Key.breed.keyString)
		self.bestFriend = try? document.unpack(Key.bestFriend.keyString)
		self.family = try document.unpack(Key.family.keyString)
	}
	
	required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Cat.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.family = (try document.unpack(Key.family.keyString)) 
		self.bestFriend = (try? document.unpack(Key.bestFriend.keyString)) 
		self.breed = (try document.unpack(Key.breed.keyString)) 
		self.name = (try document.unpack(Key.name.keyString)) 
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
