import Foundation
import MongoKitten

extension Sequence where Element : _ReferenceProtocol {
    public func resolveUnordered(filter: Query = Query(), sortedBy sort: Sort? = nil, skipping skip: Int? = nil) throws -> AnySequence<Element.M> {
        let ids = self.map { $0.reference }
        let query: Query = "_id".in(ids)
        
        return try Element.M.find(query, sortedBy: sort, skipping: skip)
    }
}

extension Sequence where Element : Model {
    public func makeReferences() -> [Reference<Element>] {
        return self.flatMap {
            Reference(to: $0)
        }
    }
}
