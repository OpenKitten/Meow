//
//  Document+Meow.swift
//  Tikcit
//
//  Created by Robbert Brandsma on 24-05-17.
//
//

import BSON
import Foundation

extension Document {
    
    public func meowHasValue<K : KeyRepresentable>(_ key: K) -> Bool {
        let val = self[key.keyString]
        
        if val is NSNull {
            return false
        }
        
        return val != nil
    }
    
}
