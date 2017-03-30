import Meow
import Vapor

try Meow.init("mongodb://localhost:27017/meow-sample")
try Meow.database.drop()

let drop = try Droplet()
Meow.integrate(with: drop)
Meow.integrateAuthentication(with: drop)

Meow.checkPermissions { route in
    switch route {
    case .User_get:
        return true
    case .User_delete:
        return false
    case .User_init:
        return true
    case .User_static_cheese:
        return true
    }
}

_ = try User.find { user in
    return user.profile.age > 20
}

try drop.run()
