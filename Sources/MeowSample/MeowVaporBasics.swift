import Foundation
import MeowVapor

// register Meow as a service in vapor. configure.swift
// let MongoURL = "mongodb://localhost/MeowSample"
// try services.register(MeowProvider(MongoURL))

// example model
// Type "Content" is needed to translate this to JSON
final class SchrodingersCat: QueryableModel, Content {
    var _id = ObjectId()
    var name: String
    var age : Int
    var alive : Bool
    
    init(name: String, age : Int, alive: Bool) {
        self.name = name
        self.age = age
        self.alive = alive
    }
}


// Save multiple extension
extension Context {
    public func save<M: Model>(_ first: M, _ instances: M...) -> EventLoopFuture<Void> {
        return save([first] + instances)
    }
    public func save<M: Model>(_ instances: [M]) -> EventLoopFuture<Void> {
        return instances.map(self.save).flatten(on: self.eventLoop)
    }
    public func delete<M: Model>(_ first: M, _ instances: M...) -> EventLoopFuture<Void> {
        return delete([first] + instances)
    }
    public func delete<M: Model>(_ instances: [M]) -> EventLoopFuture<Void> {
        return instances.map(self.delete).flatten(on: self.eventLoop)
    }
}


struct CatController {

    enum ExampleErrors: Error {
        case NotFound
        case NotDeleted
        case NotSaved
        case NotUpdated
    }
    
    func register(to router: Router) {
        
        // Save multiple instances
        router.get("createCats") { req -> Future<String> in
            return req.meow().flatMap { context in
                let henk = SchrodingersCat(name: "Henk", age: 4, alive: true)
                let jan = SchrodingersCat(name: "Jan", age: 3, alive: true)
                let fred = SchrodingersCat(name: "Fred", age: 5, alive: false)
                
                return context.save(henk, jan, fred).map {
                    return "Succesfully saved multiple instances."
                }.catchMap { error in
                    return "Failed to save : \(error)"
                }
            }
        }
        
        // findOne : String
        router.get("findOneCatString") { req -> Future<SchrodingersCat> in
            return req.meow().flatMap { context in
                return context.findOne(SchrodingersCat.self, where: "name" == "henk").unwrap(or: ExampleErrors.NotFound)
            }
        }
        
        // findOne : Int
        router.get("findOneCatInt") { req -> Future<SchrodingersCat> in
            return req.meow().flatMap { context in
                return context.findOne(SchrodingersCat.self, where: "age" == 3).unwrap(or: ExampleErrors.NotFound)
            }
        }
        
        // findOne : Bool
        router.get("findOneCatBool") { req -> Future<SchrodingersCat>  in
            return req.meow().flatMap { context in
                return context.findOne(SchrodingersCat.self, where: "alive" == true).unwrap(or: ExampleErrors.NotFound)
            }
        }
        
        // find (multiple)
        
        // select all
        
        // select like %string%
        
        // New record
        router.get("newCat") { req -> Future<SchrodingersCat> in
            return req.meow().flatMap { context in
                let henk = SchrodingersCat(name: "Henk", age: 4, alive: true)
                return context.save(henk).transform(to: henk)
            }
        }

        // Update record
        router.get("updateCat") { req -> Future<SchrodingersCat> in
            return req.meow().flatMap { context in
                return try context.findOne(SchrodingersCat.self, where: \.name == "henk").unwrap(or: ExampleErrors.NotUpdated).flatMap{ entity in
                    entity.age = 16
                    return context.save(entity).transform(to: entity)
                }
            }
        }

        
        // Delete record
        router.get("deleteCat") { req -> Future<Response> in
            return req.meow().flatMap { context -> Future<Void> in
                return context.findOne(SchrodingersCat.self, where: "name" == "henk").unwrap(or: ExampleErrors.NotFound).flatMap { cat in
                    return context.delete(cat)
                }
            }.transform(to: req.response())
        }
//
//        // Remove collection // drop not yet implemented?
//        router.get("removeCatCollection") { req -> Response in
////            return req.meow().flatMap { context in
////                return context.manager.collection(for: SchrodingersCat.self).drop()
////            }.map {
////                return req.response()
////            }
//        }
        
    }
}


