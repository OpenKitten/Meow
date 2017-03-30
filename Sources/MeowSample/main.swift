import Meow
import Vapor

try Meow.init("mongodb://localhost:27017/meow-sample")
try Meow.database.drop()

let drop = try Droplet()
Meow.integrate(with: drop)

drop.get("users", User.init) { request, user in
    return user
}

drop.get("users/by-username", User.byUsername) { request, user in
    return user
}

drop.get("users", User.init, "profile-picture") { _, user in
    guard let profile = user.profile else {
        throw Abort.notFound
    }
    
    return try profile.picture.makeResponse()
}

try drop.run()
