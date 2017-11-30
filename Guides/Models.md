# Models

Meow Models are written in Swift classes and need to conform to `Model`

The only protocol requirement is the implementation of `var _id = ObjectId()`.

```swift
import Meow

class User: Model {
    var _id = ObjectId()
}
```

In this User model you can add any `Codable` type. Almost all Swift and Foundation types are `Codable`.

Optionals that are nil are not stored, optionals with a value are.

```swift
import Meow
import Foundation

class User: Model {
    var _id = ObjectId()

    var username: String
    var passwordHash: Data

    init(named name: String, passwordHash: Data) {
        self.username = name
        self.passwordHash = passwordHash
    }
}
```

## Save and delete

Models are **not** saved by default.

```swift
let user = user(named: "Piet", passwordHash: ...)

try user.save()
```

The above `.save()` function is used for saving the model.

Deleting a model is equally simple:

```swift
try user.delete()
```

## Collection

Models are saves in the collection *exactly* matching the type name.

If you change the model's name or want to use a different location you can override the collection.

```swift
class MyModel: Model {
    static let collection = Meow.db["my-collection-name"]

    ...
}
```

## Relations

Relations are taken care of using a `Reference<RelatedType>` where the `RelatedType` is a Model.

***WARNING***

You *can* store the RelatedType directly in a variable, but this will **not** be a reference. This will be a copy instead.

```swift
import Meow
import Foundation

class User: Model {
    ...

    var bestFriend: Reference<User>?

    ...
}
```

You can set this reference using the `Refence(to: ...)` initializer.

```swift
let user = User(named: "Henk", passwordHash: ...)
let otherUser = User(named: "Klaar", passwordHash: ...)

user.bestFriend = Reference(to: otherUser)
```

## Multiple relations

If you're storing a one-to-many relationship it's recommended to refer the "many" side to the one.

If you still need to store multiple references you can store the references in a sequence (such as an `Array` or `Set`).

```swift
let friends = [Reference<User>]()

let friend: User = ...

friends.append(Reference(to: friend))
```

### Resolving a reference

Resolving one or more references is done through the `.resolve()` function.

If a single reference is broken, this will result in an error being thrown.
For multiple references it will return all non-broken references.

If you need to ensure all references are valid, check the result's `count` against the fetched `count`.

```swift
if let bestFriendReference = user.bestFriend {
    let bestFriend: User = try bestFriendReference.resolve()
}

let friends = try user.friends.resolve()
```

## Designing models

Models should be designed as you would with any Swift type.

If a type would be shared between multiple models, do that.

```swift
struct ContactInfo: Codable {
    var email: String
    var phoneNumber: String
    var firstName: String
    var lastName: String
}

class User: Model {
    var _id = ObjectId()

    var username: String
    var contact: ContactInfo
}

class Company: Model {
    var _id = ObjectId()

    var companyName: String
    var contact: ContactInfo
}
```
