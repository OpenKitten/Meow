import Meow
import MeowVapor
import Vapor

try! Meow.init("mongodb://localhost:27017/meow-sample")
try! Meow.database.drop()

let henk = User(email: "henk@example.com", name: "Henk", gender: .undecided)
try! henk.save()

let otherHenk = try User.findOne { $0.email == "henk@example.com" }

guard henk === otherHenk! else {
    fatalError()
}

let drop = try Droplet()
Meow.integrate(with: drop)
try drop.run()
