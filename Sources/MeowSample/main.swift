import Meow

try Meow.init("mongodb://localhost/MeowSample")

class Cat: Model {
    var _id = ObjectId()
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

try Cat.collection.remove()

let cat = Cat(name: "Henkie")
try cat.save()

let otherCat = Cat(name: "Fredje")
try otherCat.save()

let foundCat = try Cat.findOne("name" == "Henkie")
print(foundCat === cat)
