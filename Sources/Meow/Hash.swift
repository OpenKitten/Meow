//
//  Hash.swift
//  Tikcit
//
//  Created by Robbert Brandsma on 11-05-17.
//
//

import Foundation
import BSON

extension Document {
    /// Hashes a Document for internal comparison
    internal var meowHash: Int {
        let bytes = self.bytes
        
        guard bytes.count > 0 else {
            return 0
        }
        
        var h = 0
        
        for i in 0..<bytes.count {
            h = 31 &* h &+ numericCast(bytes[i])
        }
        
        return h
    }
}
