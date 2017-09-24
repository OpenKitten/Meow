# Query

Meow's basic queries rely on MongoKitten Query objects.

This document will use the following model as an example:

```swift
class User: Model {
    var _id = ObjectId()
    var username: String
    var age: Int
    var registerDate: Date
}
```

## Basic Queries

MongoKitten queries work using the literal variable name as a String, a Swift operator and a value.

### Finding multiple entities

```swift
// 1 hour * 24 (hours in a day) * 31 days (the longest month)
let oneMonthAgo = Date().addingTimeInterval(-(3600 * 24 * 31))

// All new users since last month
let newUsers = try User.find("registerDate" >= oneMonthAgo)
```

Multiple results are returned as an `AnySequence`. This makes it iterable and efficient.

```swift
for user in newUsers {
    print(user.username)
}
```

If you need them as an array:

```swift
let users = Array(newUsers)
```

### Finding a single entity

Finding a single entity is probably one of the more common tasks.

```swift
guard let user = User.findOne("username" == "Henk") else {
    ...
}
```

## Type safe

Type-safe queries are supported for models that conform to `KeyPathListable`.
Swift 4.0 doesn't yet support relating a type-safe key to a String because of access modifiers.

The requirement is the implementation of a dictionary referencing all keys.

```swift
extension User: KeyPathListable {
    static var allKeyPaths: [String : AnyKeyPath] = [
        "_id": \._id,
        "username": \.username,
        "email": \.email,
        "age": \.age,
        "registerDate": \.registerDate,
    ]
}
```

After this, you can access types more "natively" using type-safety.

This way you're guaranteed to get a compiler error if the models change. This way your compiler will show you the problem compile-time.

```swift
// 1 hour * 24 (hours in a day) * 31 days (the longest month)
let oneMonthAgo = Date().addingTimeInterval(-(3600 * 24 * 31))

// All new users since last month
let newUsers = try User.find(\.registerDate >= oneMonthAgo)
```
