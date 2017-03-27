import Meow
import Vapor

try! Meow.init("mongodb://localhost:27017/meow-sample")
try! Meow.database.drop()

let henk = User(email: "henk@example.com", name: "Henk")
try! henk.save()

let otherHenk = try User.findOne { $0.email == "henk@example.com" }

guard henk === otherHenk! else {
    fatalError()
}
