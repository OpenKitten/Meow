# 🐈 Meow

Meow is a **boilerplate-free** object persistence framework for Swift and MongoDB, from the creators of [MongoKitten](https://github.com/openkitten/mongokitten). 

It manages your database for you, so you can focus on writing your application.

⚠️ We are currently reviewing the possibility of building Meow on top of the Swift 4 Codable protocols. A final, stable release of Meow will probably not be available before the final release of Swift 4.

## ⭐️ Features

- [x] Boilerplate-free
- [x] So easy it will make you purr, or have your money back!
- [x] Awesome type-safe and autocompleted queries that feel like filtering an array
- [x] Support for custom MongoDB queries
- [x] Easy migrations to a new model version
- [x] Supports your own types (like structs and enums) and common types (like String, Int and Date) out of the box with zero configuration
- [x] Uses the full power of MongoDB
- [x] Generated code is 100% Linux-compatible

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

## 🎮 Command Line Interface

We provide a command line interface with Meow, located in the root of the package. To be able to use it, place the following script somewhere in your `$PATH` and call it `meow`:

```bash
#!/bin/bash

DIRNAME=${PWD##*/}
pkgName="Meow"	
if [[ $DIRNAME == "$pkgName" ]]; then
	PACKAGE_DIR="."
elif [ -d "Packages/Meow" ]; then
	PACKAGE_DIR="Packages/$pkgName"
else
	PACKAGE_DIR=$(echo ".build/checkouts/$pkgName.git"*)
	
	if [ ! -d $PACKAGE_DIR ]; then
		echo "❗️  Error: Meow was not found. Install it using the Swift Package Manager, the run this command again from the root of your package."
		exit 1
	fi
fi
$PACKAGE_DIR/Meow "$@"
```

We'll provide an easier way to install this script in the future. Contributions are welcomed, of course!

### Generating code

You run `meow` like you run [Sourcery](https://github.com/krzysztofzablocki/Sourcery), but without the `--templates` argument.

`meow --sources Sources/MyModule --output Sources/MyModule/Meow.swift`

### Meowfile

You can store your `meow` arguments in a `Meowfile` at the root of your project. For example:

`--sources Sources/MyModule --output Sources/MyModule/Meow.swift`

If you provide no arguments to `Meow`, it will load them from the `Meowfile`.

### Plugins

To use Meow plugins, place a `MeowPlugins` file at the root of your Swift package. This file contains a list of plugin names (the same as the Swift package they come in), separated by newlines. Plugins provide a `MeowPlugin.ejs` template file in the root directory of their package.

We don't have any documentation on writing plugins yet.

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
<summary>Linux support</summary>

**Generated code is fully Linux-compatible.** However, because Sourcery does not support Linux at the moment, code generation is only possible on macOS.

We recommend committing the generated code into your application repo. That way you can use the generated code on your Linux machine, as long as your development environment is on macOS.
</details>

<details>
<summary>Attribution</summary>

- Meow includes [Pluralize](https://github.com/blakeembrey/pluralize), which is also licensed under the MIT license

</details>
