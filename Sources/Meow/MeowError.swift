/// Generic errors thrown by the generator
public enum MeowError : Swift.Error {
    case infiniteRecursiveReference(from: _Model.Type, to: _Model.Type)
    
    /// The value for the given key is missing, or invalid
    case missingOrInvalidValue(key: String, expected: Any.Type, got: Any?)
    
    /// The value is invalid
    case invalidValue(key: String, reason: String)
    
    /// A reference to `type` with id `id` cannot be resolved
    case referenceError(id: ObjectId, type: _Model.Type)
    
    /// An object cannot be deleted, because of `reason`
    case undeletableObject(reason: String)
    
    /// A file cannot be stored because it exceeds the maximum size
    case fileTooLarge(size: Int, maximum: Int)
    
    /// One or more errors occurred while mass-deleting objects. The `errors` array contains the specific object identifier and error pairs.
    case deletingMultiple(errors: [(ObjectId, Swift.Error)])
    
    /// Meow was not able to validate the database, because `reason`
    case cannotValidate(reason: String)
    
    /// An infinite reference loop has occurred while trying to deserialize an object.
    /// This happens if you reference objects like this: `a` -> `b` -> `a`
    ///
    /// That's bad practice, both under ARC and in Meow. Meow is not able to instantiate `a`
    /// nor `b` in the above example, because it would create an infinite loop while trying to
    /// resolve the references.
    ///
    /// You can solve the infinite reference loop by making one of the references lazy, by
    /// using the `Reference` type. So instead of `var myReference: MyModel`, you would use
    /// `var myReference: Reference<MyModel>`.
    case infiniteReferenceLoop(type: _Model.Type, id: ObjectId)
    
    /// The file cannot be found in GridFS
    case brokenFileReference(ObjectId)
}
