import Foundation

public enum Operation {
    case set(to: Primitive?)
    case increment(by: Int)
    case unset
    case none
}

public struct UpdateNumber : ExpressibleByNilLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public private(set) var operation: Operation
    
    init() {
        self.operation = .none
    }
    
    public static var unaffected: UpdateNumber {
        return UpdateNumber()
    }
    
    public init(nilLiteral: ()) {
        self.operation = .unset
    }
    
    public init(floatLiteral value: Double) {
        self.operation = .set(to: value)
    }
    
    public init(integerLiteral value: Int) {
        self.operation = .set(to: value)
    }
}

public struct UpdateString : ExpressibleByStringLiteral, ExpressibleByNilLiteral {
    public private(set) var operation: Operation
    
    init() {
        self.operation = .none
    }
    
    public static var unaffected: UpdateString {
        return UpdateString()
    }
    
    public init(nilLiteral: ()) {
        self.operation = .unset
    }
    
    public init(stringLiteral value: String) {
        self.operation = .set(to: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.operation = .set(to: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.operation = .set(to: value)
    }
}
