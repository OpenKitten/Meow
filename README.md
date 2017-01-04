# Puss

Puss (work in progress) is an object persistence framework for Swift and MongoDB. Using Puss, your models can look like this:

```swift
import Puss

final class User : Model {
    var id = ObjectId()
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    
    init(email: String) {
        self.email = email
        self.registrationDate = Date()
    }
}
```

Puss relies on [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for code generation.

### Usage

1. Define your models as shown above.
2. Initialize Puss before using it:
   
   ```swift
   import Puss
   
   
	let server = try! Server(hostname: "127.0.0.1")
	let db = server["puss"]
	
	Puss.init(db)
   ```
3. That's all. You can now enjoy Puss:
   
   ```swift
   for user in try User.find() {
       print("Found user with email: \(user.email)")
	}
   ```