# Hooks

Meow exposes hooks in a few places. If you miss a hook, make an issue on [github](https://github.com/OpenKitten/Meow) or a PR.

## Model lifetime hooks

Models expose hooks before/after save and delete. These can be used to prevent the operation (by throwing) or apply other operations such as cleaning up references (to this model) after this model has been deleted.

### On a model

The following functions can be implemented on a model itself.

```swift
class MyModel: Model {
    ...

    func willSave() throws {
        // Throwing will prevent saving.
    }

    func didSave() throws {
        // Cannot prevent saving. Throwing an error will result in an error on the `.delete()` caller
    }

    func willDelete() throws {
        // Throwing will prevent deletion.
    }

    func didDelete() throws {
        // Cannot prevent deletion. Throwing an error will result in an error on the `.delete()` caller
    }
}
```

### TransactionMiddleware

The above hooks can be applied globally by a `TransactionMiddleware`

```swift
struct DoNotPersistError: Swift.Error {}

class PreventPersistenceMiddleware: TransactionMiddleware {
    func willSave(instance: _Model) throws {
        // Prevent all operations
        throw DoNotPersistError()
    }

    func didSave(instance: _Model) throws {
        fatalError("This never happens, because `willSave` throws")
    }

    func willDelete(instance: _Model) throws {
        // Prevent all operations
        throw DoNotPersistError()
    }

    func didDelete(instance: _Model) throws {
        fatalError("This never happens, because `willDelete` throws")
    }

    init() {}
}
```

Registering a middleware is done on the `Meow.middleware`:

```swift
Meow.middleware.append(PreventPersistenceMiddleware())
```

## The pool

All Meow Models pass through the `Meow.ObjectPool`. The `Meow.pool` static variable contains the ObjectPool's singleton.

Meow can keep strong references to the most recently accessed instances. This is `0` by default, but can be configured otherwise for caching.

If configured to `> 0`, Meow will try to fetch the model from the pool instead, preventing unnecessary database queries and increasing the application performance.

```swift
Meow.pool.strongReferenceAmount = 500 // cache the 500 most recently accessed models
```

Using this feature *can* in very rare instances cause a crash if one model's variable is accessed by 2 threads in the same CPU cycle. Is it, however, **extremely** rare. This can be worked around using lock/mutex.

The pool's count can be read using `Meow.pool.count` to see how many instances are cached.

And if necessary it's possible to remove (part of) the references from pool, too.

```swift
Meow.pool.removeStrongReferences()
Meow.pool.removeStrongReferences(keep: 100)
```
