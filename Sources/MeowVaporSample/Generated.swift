// Generated using Sourcery 0.5.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow



  func meowReinstantiateObjectIdArray(from source: Primitive?) throws -> [ObjectId]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> ObjectId in
          return try Meow.Helpers.requireValue(ObjectId(rawValue), keyForError: "index \(index) on array of ObjectId")
      }
  }


  func meowReinstantiateStringArray(from source: Primitive?) throws -> [String]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> String in
          return try Meow.Helpers.requireValue(String(rawValue), keyForError: "index \(index) on array of String")
      }
  }


  func meowReinstantiateIntArray(from source: Primitive?) throws -> [Int]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int in
          return try Meow.Helpers.requireValue(Int(rawValue), keyForError: "index \(index) on array of Int")
      }
  }


  func meowReinstantiateInt32Array(from source: Primitive?) throws -> [Int32]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int32 in
          return try Meow.Helpers.requireValue(Int32(rawValue), keyForError: "index \(index) on array of Int32")
      }
  }


  func meowReinstantiateBoolArray(from source: Primitive?) throws -> [Bool]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Bool in
          return try Meow.Helpers.requireValue(Bool(rawValue), keyForError: "index \(index) on array of Bool")
      }
  }


  func meowReinstantiateDocumentArray(from source: Primitive?) throws -> [Document]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Document in
          return try Meow.Helpers.requireValue(Document(rawValue), keyForError: "index \(index) on array of Document")
      }
  }


  func meowReinstantiateDoubleArray(from source: Primitive?) throws -> [Double]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Double in
          return try Meow.Helpers.requireValue(Double(rawValue), keyForError: "index \(index) on array of Double")
      }
  }


  func meowReinstantiateDataArray(from source: Primitive?) throws -> [Data]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Data in
          return try Meow.Helpers.requireValue(Data(rawValue), keyForError: "index \(index) on array of Data")
      }
  }


  func meowReinstantiateBinaryArray(from source: Primitive?) throws -> [Binary]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Binary in
          return try Meow.Helpers.requireValue(Binary(rawValue), keyForError: "index \(index) on array of Binary")
      }
  }


  func meowReinstantiateDateArray(from source: Primitive?) throws -> [Date]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Date in
          return try Meow.Helpers.requireValue(Date(rawValue), keyForError: "index \(index) on array of Date")
      }
  }


  func meowReinstantiateRegularExpressionArray(from source: Primitive?) throws -> [RegularExpression]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> RegularExpression in
          return try Meow.Helpers.requireValue(RegularExpression(rawValue), keyForError: "index \(index) on array of RegularExpression")
      }
  }

      // Struct or Class extension
      extension User : ConcreteSerializable {

      


        convenience init?(meowValue: Primitive?) throws {
          guard let document = Document(meowValue) else {
            return nil
          }

          try self.init(document: document)
        }

        func serialize() -> Document {
            return serialize(resolvingReferences: false)
        }

        func serialize(resolvingReferences: Bool) -> Document {
          var document = Document()
            document["_id"] = self._id
          
            document["username"] = self.username 
            document["email"] = self.email 
            document["gender"] = self.gender?.serialize() 
            document["profile"] = self.profile?.serialize() 
            document["password"] = self.password 
          return document
        }

        struct VirtualInstance {
          var keyPrefix: String

          
             /// username: String
              var username: VirtualString { return VirtualString(name: keyPrefix + "username") } 
             /// email: String
              var email: VirtualString { return VirtualString(name: keyPrefix + "email") } 
             /// gender: Gender?
              var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: keyPrefix + "gender") } 
             /// profile: Profile?
              var profile: Profile.VirtualInstance { return Profile.VirtualInstance(keyPrefix: keyPrefix + "profile") } 
             /// password: Data
              var password: VirtualData { return VirtualData(name: keyPrefix + "password") } 

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        } // end VirtualInstance

        enum Key : String {            case _id
          
            case username          
            case email          
            case gender          
            case profile          
            case password          

            var keyString: String { return self.rawValue }
        }

      } // end struct or class extension of User
  
        extension User : ConcreteModel {
          static let meowCollection: MongoKitten.Collection = Meow.database["user"]
          var meowReferencesWithValue: ReferenceValues { return [] }

          static func find(_ closure: ((VirtualInstance) -> (Query))) throws -> CollectionSlice<User> {
            let query = closure(VirtualInstance())
            return try self.find(query)
          }

          static func findOne(_ closure: ((VirtualInstance) -> (Query))) throws -> User? {
            let query = closure(VirtualInstance())
            return try self.findOne(query)
          }

          static func count(_ closure: ((VirtualInstance) -> (Query))) throws -> Int {
            let query = closure(VirtualInstance())
            return try self.count(query)
          }

          static func createIndex(named name: String? = nil, withParameters closure: ((VirtualInstance, IndexSubject) -> ())) throws {
            let indexSubject = IndexSubject()
            closure(VirtualInstance(), indexSubject)

            try meowCollection.createIndexes([(name: name ?? "", parameters: indexSubject.makeIndexParameters())])
          }
        }
      
    func meowReinstantiateUserArray(from source: Primitive?) throws -> [User]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> User in
            return try Meow.Helpers.requireValue(User(meowValue: rawValue), keyForError: "index \(index) on array of User")
        }
    }
  
      // Enum extension
      extension Gender : ConcreteSingleValueSerializable {
        /// Creates a `Gender` from a BSON Primtive
        init?(meowValue: Primitive?) throws {
          
            guard let rawValue = String(meowValue) else {
                return nil
            }

            switch rawValue {
               case "male": self = .male
               case "female": self = .female
              
              default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
            }
          
        }

        func serialize(resolvingReferences: Bool) -> Primitive {
            return self.serialize()
        }

        func serialize() -> Primitive {
          
            switch self {
                          case .male: return "male"
                          case .female: return "female"
              
            }
          
        }

        struct VirtualInstance {
          /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
          static func ==(lhs: VirtualInstance, rhs: Gender?) -> Query {
            return lhs.keyPrefix == rhs?.serialize()
          }

          var keyPrefix: String

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        }
      }
    
    func meowReinstantiateGenderArray(from source: Primitive?) throws -> [Gender]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> Gender in
            return try Meow.Helpers.requireValue(Gender(meowValue: rawValue), keyForError: "index \(index) on array of Gender")
        }
    }
  
      // Struct or Class extension
      extension Profile : ConcreteSerializable {
      
      init(document source: Document) throws {
          
        
          self.name = try Meow.Helpers.requireValue(String(source[Key.name.keyString]), keyForError: "name")  /* String */ 
          self.age = try Meow.Helpers.requireValue(Int(source[Key.age.keyString]), keyForError: "age")  /* Int */ 
          self.picture = try File(source[Key.picture.keyString])  /* File? */ 

        
      }
      


         init?(meowValue: Primitive?) throws {
          guard let document = Document(meowValue) else {
            return nil
          }

          try self.init(document: document)
        }

        func serialize() -> Document {
            return serialize(resolvingReferences: false)
        }

        func serialize(resolvingReferences: Bool) -> Document {
          var document = Document()
            
          
            document["name"] = self.name 
            document["age"] = self.age 
            document["picture"] = self.picture?.id 
          return document
        }

        struct VirtualInstance {
          var keyPrefix: String

          
             /// name: String
              var name: VirtualString { return VirtualString(name: keyPrefix + "name") } 
             /// age: Int
              var age: VirtualNumber { return VirtualNumber(name: keyPrefix + "age") } 
             /// picture: File?
             

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        } // end VirtualInstance

        enum Key : String {            case _id
          
            case name          
            case age          
            case picture          

            var keyString: String { return self.rawValue }
        }

      } // end struct or class extension of Profile
  
    func meowReinstantiateProfileArray(from source: Primitive?) throws -> [Profile]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> Profile in
            return try Meow.Helpers.requireValue(Profile(meowValue: rawValue), keyForError: "index \(index) on array of Profile")
        }
    }
  
// Serializables parsed: User,Gender,Profile
// Tuples parsed: 
import Foundation
import Meow
import MeowVapor
import Vapor
import Cheetah
import HTTP
import Cheetah
import ExtendedJSON

extension User : Authenticatable {
    public static func resolve(byId identifier: ObjectId) throws -> User? {
        guard let document = try User.meowCollection.findOne("_id" == identifier) else {
            return nil
        }

        return try Meow.pool.instantiateIfNeeded(type: User.self, document: document)
    }
}
extension User {
    public convenience init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
extension User {
  public func makeJSONObject() -> JSONObject {
      var object: JSONObject = [
          "id": self._id.hexString
      ]


      return object
  }
}


extension Gender {
    public init(jsonValue: Cheetah.Value?) throws {
    
        let rawValue = try Meow.Helpers.requireValue(String(jsonValue), keyForError: "enum Gender")
        switch rawValue {
         case "male": self = .male
         case "female": self = .female
        
          default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
        }
    
  }
}
extension Gender {
  public func makeJSONObject() -> JSONObject {
      let object: JSONObject = [:]


      return object
  }
}

extension Profile {
    public init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
extension Profile {
  public func makeJSONObject() -> JSONObject {
      var object: JSONObject = [:]


      return object
  }
}


extension User : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSONObject().makeResponse()
    }

    public convenience init?(from string: String) throws {
        let objectId = try ObjectId(string)

        guard let selfDocument = try User.meowCollection.findOne("_id" == objectId) else {
            return nil
        }

        try self.init(document: selfDocument)
    }

    fileprivate static func integrate(with droplet: Droplet, prefixed prefix: String = "/") {
        droplet.get("users", User.init) { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.User_get(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.User_get(subject)) { request in
                    return subject
                }
            }
        }

        droplet.delete("users", User.init) { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.User_delete(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.User_delete(subject)) { request in
                    try subject.delete()
                    return Response(status: .ok)
                }
            }
        }

        droplet.post("users") { request in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.User_init) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.User_init) { request in
                    guard let object = request.jsonObject else {
                        throw Abort(.badRequest, reason: "No JSON object provided")
                    }
            
                    guard let username = String(object["username"]) else {
                        throw Abort(.badRequest, reason: "Invalid key \"username\"")
                    }
                
                    guard let password = String(object["password"]) else {
                        throw Abort(.badRequest, reason: "Invalid key \"password\"")
                    }
                
                    guard let email = String(object["email"]) else {
                        throw Abort(.badRequest, reason: "Invalid key \"email\"")
                    }
                
                    let gender: Gender?

                    if let genderJSON = String(object["gender"]) {
                        gender = try Gender(meowValue: genderJSON)
                    } else {
                        gender = nil
                    }
                      
                    let profile: Profile?

                    if let profileJSON = object["profile"] {
                        profile = try Profile(jsonValue: profileJSON)
                    } else {
                        profile = nil
                    }
                    let subject = try User.init(username: username, password: password, email: email, gender: gender, profile: profile)
                    try subject.save()
                    let jsonResponse = subject.makeJSONObject()

                    return Response(status: .created, headers: [
                        "Content-Type": "application/json; charset=utf-8"
                    ], body: Body(jsonResponse.serialize()))
                }
            }
        }
    }
}

extension Meow {
    public static func integrate(with droplet: Droplet) {
        AuthenticationMiddleware.default.models.append(User.self)
        
        User.integrate(with: droplet)
    }
}

enum MeowRoutes {
    case User_get(User)
    case User_delete(User)
    case User_init
}

extension Meow {
    static func checkPermissions(_ closure: @escaping ((MeowRoutes) throws -> (Bool))) {
        AuthorizationMiddleware.default.permissionChecker = { route in
            guard let route = route as? MeowRoutes else {
                return false
            }

            return try closure(route)
        }
    }

    static func requireAuthentication(_ closure: @escaping ((MeowRoutes) throws -> (Bool))) {
        AuthenticationMiddleware.default.authenticationRequired = { route in
            guard let route = route as? MeowRoutes else {
                return false
            }

            return try closure(route)
        }
    }
}