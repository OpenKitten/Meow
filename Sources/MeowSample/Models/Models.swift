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
		self.name = try document.unpack("name")
		self.country = try? document.unpack("country")
		self.origin = try? document.unpack("origin")
		self.kaas = try document.unpack("kaas")
		self.geval = try? document.unpack("geval")
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
		self.name = try document.unpack("name")
		self.breed = try document.unpack("breed")
		self.bestFriend = try? document.unpack("bestFriend")
		self.family = try document.unpack("family")
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
