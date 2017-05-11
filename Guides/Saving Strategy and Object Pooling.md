# Meow Object Pool and Saving Strategy

Meow is designed to work primarily for server side applications that have a long lifespan. The object pooling mechanism and saving strategy is a result of this.

This document explains the general workings of the mechanism.

## The pool

Meow objects are automatically added to the object pool on creation, whenever possible. The object pool holds weak references to all alive objects and ensures no more than two instances with the same `ObjectId` can exist at the same time.

For every object, the object pool stores the instantiation date & time, along with a lightweight hash. This hash is used for the autosave mechanism.

## Saving

Meow will save an object under the following circumstances:

- The contents of the object have changed since the last save, and the user calls `save()`
- The user calls `save(force: true)`
- The object is being deallocated and its contents have changed since the last save
- The program exits and the contents of the object have changed since the last save
- During maintenance, if object is older than the minimum object lifespan for autosaving (defaults to 5 seconds), and the contents of the object have changed since the last save

The minimum lifespan for objects to be autosaved can be configured by setting `Meow.minimumAutosaveAge` to a custom value.

## The maintenance loop

Meow has a background process, started by `Meow.init`, that handles some cleanup work as well as the autosaving of objects. By default, the autosave loop is scheduled 5 seconds after the previous loop iteration finished.

The maintenance interval can be configured by setting `Meow.maintenanceInterval` to a custom value.

## Custom `init` catch

Meow cannot automatically pool instances of objects that are created within a custom `init`, because it has no way of knowing these objects are created. Under most circumstances, this is not a problem, because the `_id` of the new model is registered with the pool and the generated code ensures that `save()` is called when the object gets deallocated. 

Hoever, ARC will not properly deallocate objects when the program is terminating. Because of this, if an object is created, but not deallocated, manually saved or manually pooled, and the instance still exists at the time the program quits, Meow is not able to save the data.

If you happen to have such objects, you can solve the problem by manually invoking `save()` on them, or pooling them by calling `Meow.pool.pool(myModel)`. You can do this in your custom initialiser.