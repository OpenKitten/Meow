import Meow

// Sample for just Meow - for MeowVapor, see the MeowVaporSample

try Meow.init("mongodb://localhost:27017/meow-sample", meows)

for collection in try! Meow.database.listCollections() {
    try! collection.remove()
}

try Cat.index([
    .name: .ascending
], named: "name", attributes: .unique)

var breed = Breed(name: "Abyssinian")
breed.country = .ethopia

try breed.save()
let abyssinian = breed

breed = Breed(name: "Brazilian Shorthair")
breed.country = .brazil
breed.origin = .natural
try breed.save()

let brazillianShorthair = breed

breed = try Breed.findOne("name" == "Abyssinian")!
breed.origin = .natural

let superCat = Cat(name: "Harrie", breed: brazillianShorthair, bestFriend: nil, family: [])
let uberSuperCat = Cat(name: "Bob", breed: abyssinian, bestFriend: superCat, family: [superCat])

superCat.family.append(uberSuperCat)
try superCat.save()
try uberSuperCat.save()

let superCatClone = try Cat.findOne("name" == "Harrie")

var referencing: CatReferencing! = CatReferencing(cat: superCat)
referencing = nil
referencing = try! CatReferencing.findOne()!
print(referencing.cat.breed.name)

print("📍 \(breed.country!)")
print(superCatClone?.breed.name ?? "nope")
print(superCatClone?.family.first?.name ?? "nope")

guard let otherSuperCatClone = try Cat.findOne({ cat in
    cat.name == "Harrie"
}) else {
    fatalError("MEOW NO! :(")
}

print(superCatClone == otherSuperCatClone)
