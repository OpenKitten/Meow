# 🐈 Meow

Meow (work in progress) is a **boilerplate-free** object persistence framework for Swift and MongoDB, from the creators of [MongoKitten](https://github.com/openkitten/mongokitten). 

It manages your database for you, so you can focus on writing your application.

## ⭐️ Features

- [x] Boilerplate-free
- [x] So easy it will make you purr, or have your money back!
- [x] Type-safe and autocompleted queries
- [ ] Type-safe and autocompleted updates
- [x] Supports your own types (like structs and enums) and common types (like String, Int and Date) out of the box with zero configuration
- [x] Uses the full power of MongoDB
- [ ] Model subclassing
- [ ] Optional integration with Vapor for amazingly simple and absurdly fast API development

*Meow 1.0 will have all these boxes checked.*

Object serialization and deserialization code is generated automatically using [Sourcery](https://github.com/krzysztofzablocki/Sourcery).

<small>Please be aware that using Meow may have side-effects such as feeling miserable for all those hours you have spent writing object serialization/deserialization code before.</small>

## ⚠️ In development

This branch contains a version that is currently being developed. It is not ready for production.

## ⌨️ Usage

### Initialisation

To get started, this is all you need:

```swift
import Meow
try Meow.init("mongodb://localhost/meow")
```

### Defining models

Start by defining models. Models are just normal Swift classes that look like this:

```swift
final class User: Model {
    var _id = ObjectId()
    var email: String
    var name: String
    var gender: Gender
    var favoriteNumbers: [Int] = []
    
    init(email: String, name: String, gender: Gender) {
        self.email = email
        self.name = name
        self.gender = gender
    }
    
    // sourcery:inline:User.Meow
    // sourcery:end
}
```

This class is a valid model, because:

- It conforms to the `Model` protocol by defining an `_id` variable
- It marks a place four Sourcery to insert a generated initializer

Sourcery and Meow will do the rest: with the definition shown above, you can now query and save users.

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

More information on how this works is specified below.

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


## ℹ About the queries

For the type-safe queries, a `struct VirtualInstance` is embedded in every type. These structs have variables with the same name as the variables in the containing type, but with different types:

```swift
var email: VirtualString { ... } 
var name: VirtualString { ... } 
var age: VirtualNumber { ... }
```

These "Virtual" types expose an API that is similar to the types provided by the Swift Standard Library. The trick here is that instead their methods return a MongoKitten `Query` instance.

## ❓Questions

<details>
<summary>`sourcery` commands for developing Meow</summary>

We provide a few scripts to facilitate this: `WatchSampleMeow.sh`, `WatchSampleMeowVapor.sh`, `GenerateTests.sh`
</details>