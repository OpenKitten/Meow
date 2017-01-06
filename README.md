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

## Preparation

### One-time

1. Add Puss to your Package.swift:
	
	```swift
	import PackageDescription
	
	let package = Package(
	    name: "PussTest",
	    dependencies: [
	        .Package(url: "https://github.com/Obbut/Puss.git", Version(0,0,0))
	    ]
	)
	```

2. Make sure [Sourcery](https://github.com/krzysztofzablocki/Sourcery) is installed.

### When making changes to your models

While working on your project, run Sourcery in daemon mode so it updates your generated code:

`sourcery Sources Packages/Puss-* Sources/Puss.generated.swift --watch`

## Usage

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
   
## Documentation

<details>
<summary>Model requirements</summary>

- Every model is a **final** class
- Every model must have a property `id` of type ObjectId
- You need to explicitly define the type of all properties you want to have serialized
</details>

<details>
<summary>Initializers and nonoptional properties</summary>

In the initialization process, Puss always uses the first defined initializer. It will match the argument names (not the labels) to the instance variable names, and pass the variables as arguments.

After calling the initializer, Puss explicitly sets every variable.

*Try viewing the generated code for your models to get a better understanding of how Puss works under the hood.*
</details>

## TODO - notes to self

```swift
User.update(matching: ...) { user in
	user.firstName = "henk"
}
```