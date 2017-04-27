import Meow

// Sample for just Meow - for MeowVapor, see the MeowVaporSample

try Meow.init("mongodb://localhost:27017/meow-sample")

try! Breed.remove()

var breed = Breed(name: "Abyssinian")
breed.country = .ethopia

breed = Breed(name: "Brazilian Shorthair")
breed.country = .brazil
breed.origin = .natural

breed = try! Breed.findOne("name" == "Abyssinian")!
breed.origin = .natural

print("📍 \(breed.country!)")
