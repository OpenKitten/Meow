# Getting Started with Meow

### Initialisation

To get started, import Meow and initialise it during your startup routine:

```swift
import Meow

try Meow.init("mongodb://localhost/meow")
```

You can initialise Meow using a MongoKitten Database object, or a MongoDB connection string.

### Defining models

Models are just normal Swift **classes** that look like this:

```swift
final class User: Model {
    var email: String
    var name: String
    var gender: Gender
    var favoriteNumbers: [Int] = []
    
    init(email: String, name: String, gender: Gender) {
        self.email = email
        self.name = name
        self.gender = gender
    }
}
```

This class is a valid model, because it states conformance to the Model protocol.

Sourcery and Meow will do the rest: with the definition shown above, you can now query and save users. Serialization and deserialization will be handled for you.

### Generating code

You run `meow` like you run [Sourcery](https://github.com/krzysztofzablocki/Sourcery), but without the `--templates` argument.

`meow --sources Sources/MyModule --output Sources/MyModule/Meow.swift`

For more information about the Meow CLI, including setting it up, please look at [the CLI documentation](cli.html).

### Queries

Queries use a syntax that will feel familiar if you ever used the `filter` syntax on a Swift array:

```swift
let users = User.find { user in
	return user.name == "henk" && user.email.hasSuffix("me.com")
}
```

```swift
let femaleCount = User.count { $0.gender == .female }
```

While it may look like we fetch every user from the database and pass it to your closure, Meow actually uses black magic to generate a MongoDB query from your closure.

For more information, look at the documentation for `BaseModel.find(...)`.

### Variable Types

Meow currently supports variables of the following kind:

- Variables of one of the BSON types: `String`, `Int`, `Int32`, `Bool`, `Document`, `Double`, `ObjectId`, `Data`, `Binary`, `Date`, and `RegularExpression`
- `enum`s that have no associated values. For example, the following enum can be used out of the box:

	```swift
	enum Gender {
		case male, female
	}
	```
	
	Support for associated values is on our todo list. If an enum has a underlying type, that type currently has to be supported by BSON.
	
- Structs defined in the same module as the model. As long as all their variables are of a kind supported by Meow (including other structs) they should work out of the box.
- Classes defined in the same module as the model. The same rules apply here as with structs. However, due to a limitation in the Swift language (designated initializers have to be defined within the class definition), these classes also need the `sourcery:inline` markers.
- Tuples of which the elements comply to the normal variable rules
