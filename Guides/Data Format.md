# Meow Data Format

This document describes, in general, the data format Meow uses to store your documents in MongoDB.

## Collection naming

The name of the collection is based on the name of the class that is stored in it. CamelCase is converted to snake_case, and the class name is made plural. Some examples (class: collection):

- `User`: `users`
- `Man`: `men`
- `CarWheel`: `car_wheels`

## Property naming

By default, property names are converted from camelCase to snake_case. For example:

- `firstName`: `first_name`
- `event`: `event`

As you can see, this mostly works, but sometimes you might want some more control. For example, for a property named `linkedIn`, Meow will by default use `linked_in` as the key. To customize this, you can place a sourcery annotation next to the variable:

```swift
// sourcery: key = linkedin
var linkedIn: String
```

## The Key enum

Meow will store all property names in an enum named `Key` in every model. You can use this enum if you ever need to acccess the raw (database) name of a property.

To access the key name of a property `MyProperty` on `MyModel`:  `MyModel.Key.myProperty.keyString`