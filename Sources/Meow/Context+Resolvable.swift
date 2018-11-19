//
//  Context+Resolvable.swift
//  Meow
//
//  Created by Robbert Brandsma on 19/11/2018.
//

import NIO

extension Context {
    public func resolve<A: Resolvable>(_ a: A) -> EventLoopFuture<A.Result> {
        return a.resolve(in: self, where: Query())
    }
    
    public func resolve<A: Resolvable, B: Resolvable>(_ a: A, _ b: B) -> EventLoopFuture<(A.Result, B.Result)> {
        return a.resolve(in: self, where: Query())
            .and(b.resolve(in: self, where: Query()))
    }

    public func resolve<A: Resolvable, B: Resolvable, C: Resolvable>(_ a: A, _ b: B, _ c: C) -> EventLoopFuture<(A.Result, B.Result, C.Result)> {
        return a.resolve(in: self, where: Query())
            .and(b.resolve(in: self, where: Query()))
            .and(c.resolve(in: self, where: Query()))
            .map { results in
                return (results.0.0, results.0.1, results.1)
        }
    }
    
    public func resolve<A: Resolvable, B: Resolvable, C: Resolvable, D: Resolvable>(_ a: A, _ b: B, _ c: C, _ d: D) -> EventLoopFuture<(A.Result, B.Result, C.Result, D.Result)> {
        return a.resolve(in: self, where: Query())
            .and(b.resolve(in: self, where: Query()))
            .and(c.resolve(in: self, where: Query()))
            .and(d.resolve(in: self, where: Query()))
            .map { results in
                return (results.0.0.0, results.0.0.1, results.0.1, results.1)
        }
    }
}
