import Meow

// Sample for just Meow - for MeowVapor, see the MeowVaporSample

try Meow.init("mongodb://localhost:27017/meow-sample")

for collection in try! Meow.database.listCollections() {
    try! collection.remove()
}

var breed = Breed(name: "Abyssinian")
breed.country = .ethopia

breed = Breed(name: "Brazilian Shorthair")
breed.country = .brazil
breed.origin = .natural

breed = try! Breed.findOne("name" == "Abyssinian")!
breed.origin = .natural

var cat = Cat(name: "Henk", breed: breed, bestFriend: nil, family: [])

Meow.pool.pool(cat)

print("📍 \(breed.country!)")
