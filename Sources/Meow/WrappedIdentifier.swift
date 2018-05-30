internal class AnyInstanceIdentifier : Hashable {
    
    fileprivate init() {}
    
    var hashValue: Int {
        assertionFailure("The HashValue implementation of AnyInstanceIdentifier should not be used")
        return 0
    }
    
    static func == (lhs: AnyInstanceIdentifier, rhs: AnyInstanceIdentifier) -> Bool {
        return lhs.equals(rhs)
    }
    
    fileprivate func equals(_ other: AnyInstanceIdentifier) -> Bool {
        assertionFailure("The AnyInstanceIdentifier method of equals should not be used")
        return false
    }
}

internal final class InstanceIdentifier<M: Model> : AnyInstanceIdentifier {
    let identifier: M.Identifier
    
    init(_ identifier: M.Identifier) {
        self.identifier = identifier
        super.init()
    }
    
    override var hashValue: Int {
        return ObjectIdentifier(M.self).hashValue ^ identifier.hashValue
    }
    
    override func equals(_ other: AnyInstanceIdentifier) -> Bool {
        guard let other = other as? InstanceIdentifier<M> else {
            // Different types
            return false
        }
        
        return other.identifier == self.identifier
    }
}
