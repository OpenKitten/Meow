// Generated using Sourcery 0.5.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import MongoKitten
import Foundation

  
public func ==(lhs: VirtualBool, rhs: Bool) -> MongoKitten.Query {
  return lhs.name == rhs
}

public func ==(lhs: VirtualData, rhs: Data) -> MongoKitten.Query {
    return lhs.name == Binary(data: rhs, withSubtype: .generic)
}

public func ==(lhs: VirtualDate, rhs: Date) -> MongoKitten.Query {
  return lhs.name == rhs
}

public func ==(lhs: VirtualNumber, rhs: MeowNumber) -> MongoKitten.Query {
  return lhs.name == rhs
}

public func ==(lhs: VirtualObjectId, rhs: ObjectId) -> MongoKitten.Query {
  return lhs.name == rhs
}

public func ==(lhs: VirtualString, rhs: String) -> MongoKitten.Query {
  return lhs.name == rhs
}



public func >(lhs: VirtualDate, rhs: Date) -> MongoKitten.Query {
  return lhs.name > rhs
}

public func <(lhs: VirtualDate, rhs: Date) -> MongoKitten.Query {
  return lhs.name < rhs
}

public func >=(lhs: VirtualDate, rhs: Date) -> MongoKitten.Query {
  return lhs.name >= rhs
}

public func <=(lhs: VirtualDate, rhs: Date) -> MongoKitten.Query {
  return lhs.name <= rhs
}

public func >(lhs: VirtualNumber, rhs: MeowNumber) -> MongoKitten.Query {
  return lhs.name > rhs
}

public func <(lhs: VirtualNumber, rhs: MeowNumber) -> MongoKitten.Query {
  return lhs.name < rhs
}

public func >=(lhs: VirtualNumber, rhs: MeowNumber) -> MongoKitten.Query {
  return lhs.name >= rhs
}

public func <=(lhs: VirtualNumber, rhs: MeowNumber) -> MongoKitten.Query {
  return lhs.name <= rhs
}

