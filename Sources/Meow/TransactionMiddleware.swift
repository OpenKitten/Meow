//
//  TransactionMiddleware.swift
//  Meow
//
//  Created by Robbert Brandsma on 02-06-17.
//
//

public protocol TransactionMiddleware {
    func willSave(instance: BaseModel) throws
    func didSave(instance: BaseModel, wasUpdated: Bool) throws
    func willDelete(instance: BaseModel) throws
    func didDelete(instance: BaseModel) throws
}

public extension TransactionMiddleware {
    public func willSave(instance: BaseModel) throws {}
    public func didSave(instance: BaseModel, wasUpdated: Bool) throws {}
    public func willDelete(instance: BaseModel) throws {}
    public func didDelete(instance: BaseModel) throws {}
}
