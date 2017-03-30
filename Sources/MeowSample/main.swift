import MeowVapor

let drop = try Droplet()

try Meow.init("mongodb://localhost:27017/meow-sample")

Meow.integrate(with: drop)
Meow.integrateAuthentication(with: drop)

Meow.checkPermissions { route in
    switch route {
    case .User_get:
        return User.current != nil
    case .User_delete(let removedUser):
        return User.current == removedUser
    case .User_init:
        return true
    }
}

try drop.run()
