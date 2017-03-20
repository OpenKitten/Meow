//
//  Indexes.swift
//  Meow
//
//  Created by Joannis Orlandos on 27/01/2017.
//
//

import MongoKitten

public class IndexSubject {
    public init() { }
    
    var sort: [(field: String, order: SortOrder)] = []
    var expire: Int? = nil
    var unique: Bool = false
    var background: Bool = false
    var text: [String] = []
    
    public func makeIndexParameters() -> [IndexParameter] {
        var parameters = [IndexParameter]()
        
        if text.count > 0 {
            parameters.append(.text(text))
        }
        
        if unique {
            parameters.append(.unique)
        }
        
        if background {
            parameters.append(.buildInBackground)
        }
        
        if let expire = expire {
            parameters.append(.expire(afterSeconds: expire))
        }
        
        if sort.count == 1 {
            parameters.append(.sort(field: sort[0].field, order: sort[0].order))
        } else if sort.count > 1 {
            parameters.append(.sortedCompound(fields: sort))
        }
        
        return parameters
    }
    
    public func makeUnique() {
        self.unique = true
    }
    
    public func buildInBackground() {
        self.background = true
    }
    
    public func makeTextIndex(onFields fields: [VirtualString]) {
        self.text = fields.map {
            $0.name
        }
    }
    
    public func makeTextIndex(onFields fields: VirtualString...) {
        self.makeTextIndex(onFields: fields)
    }
}
