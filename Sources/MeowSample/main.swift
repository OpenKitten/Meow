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

// DELETE /users/12313431513
drop.delete("users", User.init) { request, user in
    try User.find { user in
        return user.profile.age > 40
    }
    
    return "OK"
}

drop.get("users", User.init, "profile-picture") { _, user in
    return try user.profile.picture.makeResponse()
}

try drop.run()
