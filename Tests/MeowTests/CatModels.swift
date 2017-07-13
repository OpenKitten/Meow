import Meow
import Foundation

public enum Numbers : Int, Codable {
    case one = 1
    case two = 2
    case three = 3
}

public class Tiger : Model, KeyPathListable {
    public static var allKeyPaths: [String : AnyKeyPath] = [
        "_id": \Tiger._id,
        "breed": \Tiger.breed
    ]
    
    public var _id = ObjectId()
    public var breed: Reference<Breed>
    public var singleBreeds: [Breed]
    public var sameSingleBreeds: [Reference<Breed>]
    
    public init(breed: Breed) {
        self.breed = Reference(to: breed)
        self.singleBreeds = [breed]
        self.sameSingleBreeds = [Reference(to: breed)]
    }
}

//public class CatReferencing : Model {
//    public var _id = ObjectId()
//    public var cat: AnyReference<CatLike>
//
//    public init(cat: CatLike) {
//        self.cat = cat
//    }
//}

public class Breed : Model, ExpressibleByStringLiteral {
    public enum Country : String, Codable {
        case ethopia, greece, unitedStates, brazil
    }
    
    public enum Origin : String, Codable {
        case natural, mutation, crossbreed, hybrid, hybridCrossbreed
    }
    
    public struct Thing : Codable {
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
    
    public var _id = ObjectId()
    public var name: String
    public var country: Country?
    public var origin: Origin?
    public var geval: Thing?
    
    public init(name: String) {
        self.name = name
    }
    
    public func purr() {
        print("Purr.")
    }
}

class Cat : Model {
    var _id = ObjectId()
    var name: String
    var breed: Reference<Breed>
    var bestFriend: Reference<Cat>?
    var family: [Reference<Cat>]
    var favouriteNumber: Numbers?
    
    init(name: String, breed: Breed, bestFriend: Cat?, family: [Cat]) {
        self.name = name
        self.breed = Reference(to: breed)
        
        if let bestFriend = bestFriend {
            self.bestFriend = Reference(to: bestFriend)
        }
        
        self.family = family.makeReferences()
    }
}

