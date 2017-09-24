# 🐈 Meow

Meow is a **boilerplate-free** object persistence framework for Swift and MongoDB, from the creators of [MongoKitten](https://github.com/openkitten/mongokitten).

It manages your database for you, so you can focus on writing your application.

## ⭐️ Features

- [x] Boilerplate-free
- [x] So easy it will make you purr, or have your money back!
- [x] Awesome type-safe and autocompleted queries that feel like filtering an array
- [x] Support for custom MongoDB queries
- [x] Easy migrations to a new model version
- [x] Supports your own types (like structs and enums) and common types (like String, Int and Date) out of the box with zero configuration
- [x] Uses the full power of MongoDB

Object serialization and deserialization code is taken care of using Codable.

<small>Please be aware that using Meow may have side-effects such as feeling miserable for all those hours you have spent writing object serialization/deserialization code before.</small>

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
	// This is the only requirement for each model
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
}
```

This class is a valid model, because it states conformance to the Model protocol and has an `_id` variable with the type of `ObjectId`.

### Queries

Queries use a syntax that will feel familiar for MongoKitten users.

```swift
let users = User.find("name" == "henk")
```

### Variable Types


- Variables of one of the BSON types: `String`, `Int`, `Int32`, `Bool`, `Document`, `Double`, `ObjectId`, `Data`, `Binary`, `Date`, and `RegularExpression`
- Codable types (will be converted to/from BSON)
- Meow References will be converted to an `ObjectId` (`Reference<MyModel>`)

```swift
enum Gender: String, Codable {
	case male, female
}
```

### Migrations

Whenever you make a breaking change to your models and you want to keep using your existing data, you will need to provide a migration. Breaking changes are:

- Adding a required property
- Renaming a property
- Changing the data type of a property

Migrations are performed on a lower level than other operations in Meow, because Meow does not know the difference between the before and after data model. Migrations look like this:

```swift
Meow.migrate("My migration description", on: MyModel.self) { migrate in
	// rename a property
	migrate.rename("foo", to: "bar")
	
	// convert a property into a new format
	migrate.map("myStringFormattedDate") { myStringFormattedDate in
		return myDateConversionFunction(myStringFormattedDate)
	}
	
	// advanced: custom document adaption
	migrate.map { document in
		// change the document
		return otherDocument
	}
}
```

From the given closure, Meow will create a migration plan. The plan is optimized into a minimum amount of database operations and then executed.

## Learn more

[We have a few guides here](Guides/Setup.md)
