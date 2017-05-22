//
//  Helpers.swift
//  Tikcit
//
//  Created by Robbert Brandsma on 11-05-17.
//
//

import Foundation
import Dispatch

// (parts of) this file are from https://github.com/vapor/core

extension Double {
    fileprivate var nanoseconds: UInt64 {
        return UInt64(self * Double(1_000_000_000))
    }
}


extension DispatchTime {
    internal init(secondsFromNow: Double) {
        let uptime = DispatchTime.now().rawValue + secondsFromNow.nanoseconds
        self.init(uptimeNanoseconds: uptime)
    }
}

extension ModelKey {
    public static func makeProjection() -> Projection {
        var doc = Document()
        
        for key in Self.all {
            doc[key.keyString] = true
        }
        
        return Projection(doc)
    }
}
