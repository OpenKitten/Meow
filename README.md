# Meow

Meow (work in progress) is an object persistence framework for Swift and MongoDB. Using Meow, your models can look like this:

```swift
import Meow

final class User : Model {
    var id = ObjectId()
    
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    var preferences = Preferences()
    var pet: Reference<Dog, Cascade>?
    var boss: Reference<User, Ignore>?
    
    init(email: String) {
        self.email = email
        self.registrationDate = Date()
    }
}
```

Meow relies on [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for code generation.

## Preparation

### One-time

1. Add Meow to your Package.swift:
	
	```swift
	import PackageDescription
	
	let package = Package(
	    name: "MeowTest",
	    dependencies: [
	        .Package(url: "https://github.com/OpenKitten/Meow.git", Version(0,0,0))
	    ]
	)
	```

2. Make sure [Sourcery](https://github.com/krzysztofzablocki/Sourcery) is installed.

### When making changes to your models

While working on your project, run Sourcery in daemon mode so it updates your generated code:

`sourcery Sources Packages/Meow-* Sources/Meow.generated.swift --watch`

## Usage

1. Define your models as shown above.
2. Initialize Meow before using it:
   
   ```swift
   import Meow
   
   try Meow.init("mongodb://localhost/meow")
   ```
3. That's all. You can now enjoy Meow:
   
   ```swift
   for user in try User.find() {
       print("Found user with email: \(user.email)")
	}
   ```

### Embeddable

You can make types `Embeddable` to store them within your own models or other embeddables (recursively).

```swift
final class Preferences : Embeddable {
    var likesCheese: Bool = false
    var likesPotatoes: Bool = false
}
```

### Querying

The query generator works with "virtual instances" of your models and embeddables. You can perform basic comparisons on these which will be converted into a database query.

```swift
try User.find { user in
	return user.firstName == "Henk"
}
```

For some types, like `String`, we also provide some common comparison operations:

```swift
try User.find { $0.contains("bob") }
```

Note the usage of `$0` to refer to the virtual instance in this case.

You can also create more complex queries:

```swift
try User.find { user in
	return user.name.hasPrefix("Henk", options: .caseInsensitive) || user.preferences.likesCheese == false
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

In the initialization process, Meow always uses the first defined initializer. It will match the argument names (not the labels) to the instance variable names, and pass the variables as arguments.

After calling the initializer, Meow explicitly sets every variable.

*Try viewing the generated code for your models to get a better understanding of how Meow works under the hood.*
</details>

<details>
<summary>`sourcery` commands for developing Meow</summary>

Watch the unit tests:

`sourcery Tests Templates Tests/MeowTests/Generated.swift --watch`

Watch the sample:

`sourcery Sources/MeowSample Templates Sources/MeowSample/Generated --watch`

Watch the internal templates:

`sourcery Sources/Meow InternalTemplates Sources/Meow/Generated.swift  --watch`
</details>

<details>
<summary>Will you change the name of this library?</summary>

Yes, before 1.0.0. It was worse before this.
</details>

## TODO - notes to self

```swift
User.update(matching: ...) { user in
	user.firstName = "henk"
}
```