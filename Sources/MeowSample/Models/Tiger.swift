//
//  Tiger.swift
//  Meow
//
//  Created by Robbert Brandsma on 01-05-17.
//
//

import Meow

protocol CatLike : BaseModel {
    var breed: Breed { get }
}

class Tiger : Model {
    var breed: Breed
    
    init(breed: Breed) {
        self.breed = breed
    }
    

// sourcery:inline:auto:Tiger.Meow
		required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Tiger.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.breed = try document.unpack("breed")
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

class CatReferencing : Model {
    var cat: CatLike
    
    init(cat: CatLike) {
        self.cat = cat
    }

// sourcery:inline:auto:CatReferencing.Meow
		required init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: CatReferencing.self, source: source, expectedPrimitive: BSON.Document.self);
		}

		Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.cat = try document.unpack("cat")
	}

	
	
	var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
