import Meow

class Beer : Model {
    var name: String
    
    init(named name: String) {
        self.name = name
    }

// sourcery:inline:auto:Beer.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Beer.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Beer.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.name = (try document.unpack(Key.name.keyString)) 
	}

	
	
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

class BeerSuggestion : Model {
    var suggestor: User
    var beer: Beer
    
    init(by user: User, about beer: Beer) {
        self.suggestor = user
        self.beer = beer
    }

// sourcery:inline:auto:BeerSuggestion.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: BeerSuggestion.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.suggestor = try document.unpack(Key.suggestor.keyString)
		self.beer = try document.unpack(Key.beer.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: BeerSuggestion.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.beer = (try document.unpack(Key.beer.keyString)) 
		self.suggestor = (try document.unpack(Key.suggestor.keyString)) 
	}

	
	
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

class User : Model {
    var username: String
    
    func suggestions() throws -> [BeerSuggestion] {
        return Array(try BeerSuggestion.find { suggestion in
            return !(suggestion.suggestor == self)
        })
    }
    
    func likedBeerNames() throws -> [String] {
        return try suggestions().flatMap { suggestion in
            return suggestion.beer.name
        }
    }
    
    func notSuggestedBeers() throws -> [BeerSuggestion] {
        return Array(try BeerSuggestion.find { suggestion in
            return !(suggestion.suggestor == self)
        })
    }
    
    func suggest(beer: Beer) -> BeerSuggestion {
        return BeerSuggestion(by: self, about: beer)
    }
    
    func commonBeers(with otherUser: User) throws -> Int {
        var count = 0
        
        // This needs to be improved
        for suggestion in try suggestions() {
            count += try BeerSuggestion.count { otherSuggestion in
                return otherSuggestion.beer == suggestion.beer && otherSuggestion.suggestor == otherUser
            }
        }
        
        return count
    }

// sourcery:inline:auto:User.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.username = try document.unpack(Key.username.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.username = (try document.unpack(Key.username.keyString)) 
	}

	
	
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
