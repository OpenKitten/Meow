import MeowVapor

let drop = try Droplet()

try Meow.init("mongodb://localhost:27017/meow-vapor-sample")

drop.post("users/authenticate") { request in
    guard let input = request.document, let username = String(input["username"]), let password = String(input["password"]) else {
        return "FAILED"
    }
    
    return try User.authenticate(username: username, password: password) ?? "Invalid login"
}

drop.get("users", User.init) { _, user in
    return user
}

let u = try User(username: "joannis", password: "kaas", email: "joannis@orlandos.nl")
try u.save()

try drop.run()
