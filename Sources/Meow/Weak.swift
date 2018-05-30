/// Wraps a value weak
struct Weak<Wrapped: AnyObject> {
    /// The wrapped value
    weak var value: Wrapped?
    
    /// Wraps a value
    init(_ value: Wrapped) {
        self.value = value
    }
}
