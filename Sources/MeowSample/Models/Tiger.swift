//
//  Tiger.swift
//  Meow
//
//  Created by Robbert Brandsma on 01-05-17.
//
//

import Meow

public protocol CatLike : BaseModel {
    var breed: Breed { get }
}

public class Tiger : Model {
    public var breed: Breed
    
    public init(breed: Breed) {
        self.breed = breed
    }
    
// sourcery:inline:auto:Tiger.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Tiger.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.breed = try document.unpack(Key.breed.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Tiger.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.breed = (try document.unpack(Key.breed.keyString)) 
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
	public required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: CatReferencing.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.cat = try document.unpack(Key.cat.keyString)
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: CatReferencing.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		
		self.cat = (try document.unpack(Key.cat.keyString)) 
	}

	
	
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
