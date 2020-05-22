# 🐈 Meow

Meow is a **boilerplate-free** object persistence framework for Swift and MongoDB, from the creators of [MongoKitten](https://github.com/openkitten/mongokitten).

It manages your database for you, so you can focus on writing your application.

### Support

For users of Vapor 4 and/or NIO 2.x, Meow is not available as a very lightweight layer as part of the [MongoKitten](https://github.com/OpenKitten/MongoKitten) repository.

## How it works

Meow has a type `Manager` that manages the database for you. You'll need one per NIO event loop. The manager is a small wrapper around MongoKitten which takes care of connecting, discovery and reconnecting.

From your manager you can create a Context, think of a context as something that is relevant within a single task. A task might be running migrations or responding to an HTTP request.

Within your Context, models are cached and references. So if you fetch the same user twice, Meow will refer back to the original instance the second time as long as it's available within the current Context. It's strongly encouraged to resolve references that rely on this mechanism.

## Creating models

When creating a Model you need to conform your `class` to `Model`. 
The only requirement is that you add a property to your model with a key of `_id` and is _not_ a computed property.

```swift
final class User: Model {
  var _id = ObjectId()
  
  ...
}
```

You can use any type for the `_id` key as long as it's a standard BSON `Primitive` type including:

- ObjectId
- String
- Double
- Int
- Int32
- `Binary` / `Data`

The following is completely legitimate:

```swift
// Stores the username in _id
final class User: Model {
  var _id: String
  
  var username: String {
    return _id
  }
  
  ...
```

By default the model name will be used for the collection name. You can customize this with a `static let collectionName: String`

```swift
final class User: Model {
  // Changes the collection name from `User` to `users`
  static let collectionName = "users"

  var _id = ObjectId()
  
  ...
```

## Queries

Queries reside within the `Context`.

### References

```swif
final class Article: Model {
  var _id = ObjectId()
  let creator: Reference<User>
  var title: String
  var text: String
  
  ...
```

The above demonstrates how a simple reference can be created to another model. In this case a User model. And below demonstrates resolving the reference.

```swift
let resolvedUser = article.creator.resolve(in: context)
```

The result in this case is an `EventLoopFuture<User>`, but if you wish to resolve the reference's target to `nil` if it doesn't exist you can simply do `article.creator.resolveIfPresent(in: context)`.

You're also able to delete the target of the reference using `reference.deleteTarget(in: context)`. This implies that resolving the normal way (not with `ifPresent`) will result in a failure.

### Unsupported MongoDB features

If a feature is unsupported by Meow, for example when it can't be type-safe, you can always fall back to [MongoKitten](https://github.com/OpenKitten/MongoKitten.git).

```swift
let database: MongoKitten.Database = context.manager.database
```

# 🐈 Community

[Join our slack here](https://slackpass.io/openkitten) and become a part of the welcoming community.

## ⭐️ Features

- [x] Boilerplate-free
- [x] So easy it will make you purr, or have your money back!
- [x] Awesome type-safe and autocompleted queries
- [x] Support for custom MongoDB queries
- [x] Easy migrations to a new model version
- [x] Supports your own types (like structs and enums) and common types (like String, Int and Date) out of the box using Codable
