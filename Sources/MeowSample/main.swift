import Meow

// Sample for just Meow - for MeowVapor, see the MeowVaporSample

try Meow.init("mongodb://localhost:27017/meow-sample")

var breed: Breed? = Breed(name: "Abyssinian")
breed!.country = .ethopia
breed = nil
