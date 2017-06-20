public protocol TransactionMiddleware {
    func willSave(instance: _Model) throws
    func didSave(instance: _Model) throws
    func willDelete(instance: _Model) throws
    func didDelete(instance: _Model) throws
}

public extension TransactionMiddleware {
    public func willSave(instance: _Model) throws {}
    public func didSave(instance: _Model) throws {}
    public func willDelete(instance: _Model) throws {}
    public func didDelete(instance: _Model) throws {}
}
