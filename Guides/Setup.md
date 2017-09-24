# Setting up Meow

Meow requires Swift 4.0 or greater to work.

You also need to install MongoDB 3.0 or greater for optimal support and have access to the MongoDB connection string.

[More about installing MongoDB here](https://docs.mongodb.com/manual/administration/install-community/)

[More about the Connection String here](https://docs.mongodb.com/manual/reference/connection-string/index.html)

## Package.swift

In your Package.swift, add the following to your `dependencies` array:

```swift
.package(url: "https://github.com/OpenKitten/Meow.git", from: "1.0.0")
```

To your target, add the `"Meow"` dependency.

```swift
.target(name: "Application", dependencies: ["Meow", ...])
```

## main.swift

To set up Meow, you need to initialize the library to your preferred MongoDB instance by proving the connection string.

```swift
import Meow

try Meow.init("mongodb://localhost/my-database-name")
```

## Learn more

[Modelling](Models.md) is one of the primary subjects of Meow.
For most people it's the only relevant part of the library, since Meow takes care of the rest.

[Hooks](Hooks.md) allow hooking into multiple operations of the ORM.
