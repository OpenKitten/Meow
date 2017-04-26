import Meow
import Foundation

final class Breed : Model {
    enum Country : String {
      case ethopia, greece, unitedStates
    }

    enum Origin {
      case natural, mutation, crossbreed, hybrid, hybridCrossbreed
    }

    var name: String
    var country: Country?
    var origin: Origin?
    var kaas: (String,String,String)

    init(name: String) {
      self.name = name
        self.kaas = (name, name, name)
    }


// sourcery:inline:auto:Breed.Meow
		init(restoring source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: Breed.self, source: source, expectedPrimitive: BSON.Document.self);
		}
		
		self._id = try document.unpack("_id")
		self.name = try document.unpack("name")
		self.country = try? document.unpack("country")
		self.origin = try? document.unpack("origin")
		self.kaas = try document.unpack("kaas")
	}
	
	
	var _id = ObjectId()
// sourcery:end
}
