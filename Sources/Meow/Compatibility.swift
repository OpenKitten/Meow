#if !swift(>=5.0)
internal extension Array {
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        return try self.index(where: predicate)
    }
}
#endif
