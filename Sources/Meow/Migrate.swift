//
//  Migrate.swift
//  Meow
//
//  Created by Robbert Brandsma on 02-05-17.
//
//

import MongoKitten
import Foundation

extension Meow {
    /// The collection finished migrations will be stored in
    private static var migrationsCollection: MongoKitten.Collection { return Meow.database["meow_migrations"] }
    
    /// Represents a single migration
    public final class Migrator {
        
        /// The migration description - must be unique but human readable
        public private(set) var description: String
        
        /// The model this migration affects
        public private(set) var model: BaseModel.Type
        
        /// A single migration step
        private enum Step {
            case update(Document)
            case map([(Document) throws -> Document]) // an array for minification purposes so maps can be chained
            
            /// Executes the migration step on the given model
            func execute(on model: BaseModel.Type) throws {
                switch self {
                case .update(let update):
                    try model.collection.update(to: update, multiple: true)
                case .map(let transforms):
                    var pendingUpdates: [(filter: Query, to: Document, upserting: Bool, multiple: Bool)] = []
                    
                    func processPending() throws {
                        try model.collection.update(bulk: pendingUpdates)
                        pendingUpdates.removeAll(keepingCapacity: true)
                    }
                    
                    for document in try model.collection.find() {
                        var current = document
                        for transform in transforms {
                            current = try transform(current)
                        }
                        pendingUpdates.append((filter: "_id" == document["_id"], to: current, upserting: false, multiple: false))
                        
                        if pendingUpdates.count > 100 {
                            try processPending()
                        }
                    }
                    
                    try processPending()
                }
            }
        }
        
        /// The migration plan with all the steps
        private var plan = [Step]()
        
        /// Initializes a new migration. Returns nil if the migration has already been performed
        fileprivate init?(_ description: String, on model: BaseModel.Type) throws {
            if try Meow.migrationsCollection.count("_id" == description) > 0 {
                return nil
            }
            
            self.description = description
            self.model = model
        }
        
        /// Executes the migration. If there are no models of the given type, the migration will be skipped.
        fileprivate func execute(_ migration: (Migrator) throws -> ()) throws {
            guard try model.collection.count() > 0 else {
                print("🐈 Skipping migration \"\(description)\"")
                try Meow.migrationsCollection.insert([
                    "_id": description,
                    "date": Date(),
                    "duration": "skipped"
                    ])
                return
            }
            
            print("🐈 Starting migration \"\(description)\"")
            
            let start = Date()
            try migration(self) // generates the plan
            try runPlan()
            let end = Date()
            
            let duration = end.timeIntervalSince(start)
            
            try Meow.migrationsCollection.insert([
                "_id": description,
                "date": Date(),
                "duration": duration
                ])
            
            print("🐈 Migration \"\(description)\" finished in \(duration)s")
        }
        
        /// Runs the migration plan.
        private func runPlan() throws {
            for step in plan {
               try  step.execute(on: model)
            }
        }
        
        /// Adds a migration step, and tries to combine it with existing steps
        private func addStep(_ step: Step) {
            guard let last = plan.last else {
                plan.append(step)
                return
            }
            
            switch (last, step) {
            case (.map(let transforms1), .map(let transforms2)):
                plan[plan.endIndex-1] = .map(transforms1 + transforms2)
            default: plan.append(step)
            }
        }
        
        /// Rename a property
        public func rename(_ property: String, to newName: String) {
            addStep(.update(["$rename": [property: newName]]))
        }
        
        /// Transform the entire model
        public func map(_ transform: @escaping (Document) throws -> (Document)) {
            addStep(.map([transform]))
        }
        
        /// Transform a single property
        public func map(_ property: String, _ transform: @escaping (BSON.Primitive?) throws -> (BSON.Primitive?)) {
            addStep(.map([{ document in
                var document = document
                document[property] = try transform(document[property])
                return document
            }]))
        }
        
        /// Remove a property from the model
        public func remove(_ property: String) {
            addStep(.update(["$unset": [property: ""]]))
        }
    }
    
    /// Perform a migration
    public static func migrate(_ description: String, on model: BaseModel.Type, migration: (Migrator) throws -> ()) throws {
        if let migrator = try Migrator(description, on: model) {
            try migrator.execute(migration)
        } else {
            print("🐈 Migration \"\(description)\" not needed")
        }
    }
}
