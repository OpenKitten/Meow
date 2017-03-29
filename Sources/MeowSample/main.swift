import Meow
import Vapor

try Meow.init("mongodb://localhost:27017/meow-sample")
try Meow.database.drop()

let drop = try Droplet()
Meow.integrate(with: drop)

drop.get("users/by-username", User.byName) { request, user in
    return user
}

try drop.run()
