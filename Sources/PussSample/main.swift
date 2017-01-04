import Puss

let server = try! Server(hostname: "127.0.0.1")
let db = server["puss"]

Puss.init(db)

print("Amount of users before: \(try! User.count())")

let henk = User(email: "testhenk@example.com")
henk.firstName = "Henk"
henk.lastName = "Testmeneer"

try! henk.save()

print("Amount of users before: \(try! User.count())")

print("User listing:")

for user in try! User.find() {
    print("Found user with email: \(user.email)")
}
