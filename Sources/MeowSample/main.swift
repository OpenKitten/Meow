import Meow
import Foundation

try Meow.init("mongodb://localhost:27017/meow-sample")

do {
    var problems = try Meow.validateDatabaseIntegrity()
    print(problems)
    
    // break all the things!
    try Meow.migrate("Test migration two", on: Breed.self) { migrate in
        migrate.remove("name")
    }
    
    problems = try Meow.validateDatabaseIntegrity()
    print(problems)
} catch {
    print(error)
    fatalError()
}

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

breed = try Breed.findOne { $0.name == "Abyssinian" }!
breed.origin = .natural

let superCat = Cat(name: "Harrie", breed: brazillianShorthair, bestFriend: nil, family: [])
let uberSuperCat = Cat(name: "Bob", breed: abyssinian, bestFriend: superCat, family: [superCat])

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

otherSuperCatClone.name = "Superket"

Thread.sleep(forTimeInterval: 6)
Thread.sleep(forTimeInterval: 6)

try Meow.migrate("Test migration", on: Breed.self) { migrate in
    migrate.remove("country")
}
