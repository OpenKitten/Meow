import Meow

class User : Model {
    enum Login {
        case password(String)
    }
    
    var name: (first: String, last: String)
    var username: String
    var login: Login?
    var friends: [ObjectId]
    
    init(username: String, firstName: String, lastName: String) {
        self.username = username
        self.name = (firstName, lastName)
        self.friends = []
    }

// sourcery:inline:auto:User.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.name = try document.unpack(Key.name.keyString)
		self.username = try document.unpack(Key.username.keyString)
		self.login = try document[Key.login.keyString] == nil ? nil : document.unpack(Key.login.keyString)
		self.friends = try document.unpack(Key.friends.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self);
		}
		
		self.friends = (try document.unpack(Key.friends.keyString)) 
		self.login = (try? document.unpack(Key.login.keyString)) 
		self.username = (try document.unpack(Key.username.keyString)) 
		self.name = (try document.unpack(Key.name.keyString)) 
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
