//
//  WeakCollection.swift
//  Meow
//
//  Created by Robbert Brandsma on 24-03-17.
//
//

struct Weak<Wrapped : AnyObject> {
    weak var value: Wrapped?
    init(_ value: Wrapped) {
        self.value = value
    }
}

struct WeakDictionary<Key : Hashable, Value : AnyObject> : Swift.Collection, ExpressibleByDictionaryLiteral {
    typealias UnderlyingDictionary = [Key : Weak<Value>]
    typealias Element = (key: Key, value: Value)
    typealias Index = UnderlyingDictionary.Index
    
    var underlyingDictionary: UnderlyingDictionary
    
    /// Creates an empty dictionary.
    init() {
        underlyingDictionary = UnderlyingDictionary()
    }
    
    /// Creates a dictionary initialized with a dictionary literal.
    init(dictionaryLiteral elements: (Key, Value)...) {
        underlyingDictionary = UnderlyingDictionary(sequence: elements.map {
            return ($0.0, Weak($0.1))
        })
    }
    
    /// Creates a dictionary with at least the given number of elements worth of storage.
    init(minimumCapacity: Int) {
        underlyingDictionary = UnderlyingDictionary(minimumCapacity: minimumCapacity)
    }
    
    func makeIterator() -> AnyIterator<Element> {
        var underlyingIterator = underlyingDictionary.makeIterator()
        return AnyIterator {
            var underlyingNext = underlyingIterator.next()
            while let unwrappedUnderlyingNext = underlyingNext {
                guard let unwrappedValue = unwrappedUnderlyingNext.value.value else {
                    underlyingNext = underlyingIterator.next()
                    continue
                }
                
                return (unwrappedUnderlyingNext.key, unwrappedValue)
            }
            return nil
        }
    }
    
    var startIndex: Index {
        return underlyingDictionary.startIndex
    }
    
    var endIndex: Index {
        return underlyingDictionary.endIndex
    }
    
    func index(after i: Index) -> Index {
        return underlyingDictionary.index(after: i)
    }
    
    subscript(index: Index) -> Element {
        fatalError("unimplemented")
    }
    
    subscript(index: Key) -> Value? {
        get {
            return underlyingDictionary[index]?.value
        }
        set {
            if let newValue = newValue {
                underlyingDictionary[index] = Weak(newValue)
            } else {
                underlyingDictionary[index] = nil
            }
        }
    }
}
