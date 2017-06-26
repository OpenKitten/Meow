//
//  KeyPathListable.swift
//  Meow
//
//  Created by Robbert Brandsma on 26-06-17.
//

public protocol KeyPathListable {
    static var allKeyPaths: [String : AnyKeyPath] { get }
}

