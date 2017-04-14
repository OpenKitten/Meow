import Foundation
import Meow

<%
// Selects all classes and structs that are either based on a model or embeddable protocol
let models = (types.based["Model"] || []);
let embeddables = (types.based["Embeddable"] || []);

// An array containing all serializable types
// Additional types may be added below, in the template itself (supporting implicit serializables)
let serializables = models.concat(embeddables);
let serializableTuples = [];

let supportedPrimitives = ["ObjectId", "String", "Int", "Int32", "Bool", "Document", "Double", "Data", "Binary", "Date", "RegularExpression"];
let numberTypes = ["Int", "Int32", "Double"];

/**
Generates code for deserializing a value from a document

@param {string} name - The name of the value to use as error key
@param {object} type - The type (e.g. variable.type), if available - required for nonprimitive values, may be null or undefined for primitives
@param {object} typeName - The typeName (required, e.g. variable.typeName)
@param {string} accessor - The accessor to the primitive
*/
function deserializeFromPrimitive(name, type, typeName, accessor) {
  if (supportedPrimitives.includes(typeName.unwrappedTypeName)) {
    if (typeName.isOptional) {
      %> <%- typeName.unwrappedTypeName %>(<%- accessor %>) <%
    } else {
      %> try Meow.Helpers.requireValue(<%-typeName.name%>(<%- accessor %>), keyForError: "<%-name%>") <%
    }
  } else if (type) {
    // Embed a custom type
    ensureSerializable(type);

    if (typeName.isOptional) {
      %> try <%-typeName.unwrappedTypeName-%>(meowValue: <%- accessor %>) <%
    } else {
      %> try Meow.Helpers.requireValue(<%-typeName.unwrappedTypeName-%>(meowValue: <%- accessor %>), keyForError: "<%-name%>") <%
    }
  } else if (typeName.isArray) {
    let elementTypeNameString = ensureSerializableArray(typeName);

    if (typeName.isOptional) {
      %> try meowReinstantiate<%- elementTypeNameString %>Array(from: <%- accessor %>) <%
    } else {
      %> try Meow.Helpers.requireValue(meowReinstantiate<%- elementTypeNameString %>Array(from: <%- accessor %>), keyForError: "<%-name%>") <%
    }
  } else if (typeName.isTuple) {
    ensureSerializable(typeName);
    if (typeName.isOptional) {
      %> try <%- makeTupleDeserializeFunctionName(typeName) %>(<%- accessor %>) <%
    } else {
      %> try Meow.Helpers.requireValue(<%- makeTupleDeserializeFunctionName(typeName) %>(<%- accessor %>), keyForError: "<%-name%>") <%
    }
  } else if(typeName.unwrappedTypeName == "File") {
    if (typeName.isOptional) {
      %> try File(<%- accessor %>) <%
    } else {
      %> try Meow.Helpers.requireValue(File(<%- accessor %>), keyForError: "<%-name%>") <%
    }
  }

  %> /* <%-typeName.name%> */ <%
}

/**
Generates code for deserializing a value into a primitive

@param {string} accessor - The accessor of the variable (e.g. self.id)
@param {object} type - The type (e.g. variable.type), if available - required for nonprimitive values, may be null or undefined for primitives
@param {object} typeName - The typeName (required, e.g. variable.typeName)
*/
function serializeToPrimitive(accessor, type, typeName) {
  if (supportedPrimitives.includes(typeName.unwrappedTypeName)) {
    %> <%- accessor %> <%
  } else if (type) {
    // Embed a custom type
    ensureSerializable(type);
    %> <%- accessor %><%- typeName.isOptional ? '?' : '';%>.meowSerialize() <%
  } else if (typeName.isArray) {
    let elementTypeNameString = ensureSerializableArray(typeName);
    if (supportedPrimitives.includes(elementTypeNameString)) {
      %> <%- accessor %> <%
    } else {
      %> <%- accessor %><%- typeName.isOptional ? '?' : '';%>.map { $0.meowSerialize() } <%
    }
  } else if (typeName.isTuple) {
    ensureSerializable(typeName);
    %> <%- makeTupleSerializeFunctionName(typeName) %>(<%- accessor %>)<%
  } else if(typeName.unwrappedTypeName == "File") {
    %> <%- accessor %><%- typeName.isOptional ? '?' : '';%>.id <%
  }
}

/**
Ensures the given type is serializable. If it is not already, it will be added to the serialization code generation queue.

@param {object} type - The type object (e.g. variable.type) or tuple instance
*/
function ensureSerializable(type) {
  if (type.isTuple) {
    let signature = makeTupleSignature(type);
    if (serializableTuples.find(t => makeTupleSignature(t) == signature)) { return };
    serializableTuples.push(type);
    return;
  }

  if(type.name == "File") { return; }

  // check if it is already in the queue, and if it is, return:
  if (serializables.find(t => t.name == type.name)) { return };
  serializables.push(type);
}

/**
Ensures the given array element is serializable. If it is not already, it will be added to the serialization code generation queue.
If the type was not found, an error is generated.

@param {object} typeName - The type name of the array
@returns {string} The parsed type name of the array
*/
function ensureSerializableArray(typeName) {
  // Work around a bug in Sourcery (the element type is not given on arrays)
  let elementTypeNameString = typeName.name.substring(1, typeName.name.length - (typeName.isOptional ? 2 : 1)); // workaround for sourcery bug

  if (supportedPrimitives.includes(elementTypeNameString)) {
    return elementTypeNameString;
  }

  let elementType = types.all.find(t => t.name == elementTypeNameString);

  if (elementType == undefined) {
    %> <#meow error: array type <%- elementTypeNameString %> was not found, is not a primitive and cannot be serialized#> <%
    return elementTypeNameString;
  }

  ensureSerializable(elementType);
  return elementTypeNameString;
}

/**
@param {object} tuple - The sourcery tuple object
@returns {string} The tuple signature
*/
function makeTupleSignature(tuple) {
  if (tuple.isTuple) {
    // The tuple is secretly a typeName
    tuple = tuple.tuple;
  }

  if (!tuple) {
    return "invalidTuple";
  }

  return tuple.elements.map(e => ((e.name || "") + e.unwrappedTypeName)).join("And");
}

/**
@param {object} tuple - The sourcery tuple object
@returns {string} The tuple serialization swift function name
*/
function makeTupleSerializeFunctionName(tuple) {
  let signature = makeTupleSignature(tuple);
  return `meowSerializeTupleOf${signature}`;
}

/**
@param {object} tuple - The sourcery tuple object
@returns {string} The tuple deserialization swift function name
*/
function makeTupleDeserializeFunctionName(tuple) {
  let signature = makeTupleSignature(tuple);
  return `meowDeserializeTupleOf${signature}`;
}

supportedPrimitives.forEach(primitive => { %>

  func meowReinstantiate<%- primitive %>Array(from source: Primitive?) throws -> [<%- primitive %>]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> <%- primitive %> in
          return try Meow.Helpers.requireValue(<%- primitive %>(rawValue), keyForError: "index \(index) on array of <%- primitive %>")
      }
  }
<% }) // end supportedPrimitives loop

// Generate serialization for every serializable
// It is important to keep this as far down as possible.
// Keep track of the serializables we already handled:
let generatedSerializables = [];
let generatedSerializableTuples = [];

function generateSerializables() {
  // The reason for looping this way is that embedded serializables may be recursive, so implicit serializables may be added while looping
  let serializableIndex = 0;
  while (serializables.length > generatedSerializables.length) {
    let serializable = serializables[serializableIndex];
    serializableIndex++;
    generatedSerializables.push(serializable);

    if (serializable.kind == "enum") {
      %>
      // Enum extension
      extension <%- serializable.name %> : ConcreteSingleValueSerializable {
        /// Creates a `<%- serializable.name %>` from a BSON Primtive
        init?(meowValue: Primitive?) throws {
          <% if (serializable.typeName) { %>
            guard let rawValue = <%- serializable.rawTypeName.name %>(meowValue) else {
                return nil
            }

            self = try Meow.Helpers.requireValue(<%- serializable.name %>(rawValue: rawValue), keyForError: "enum <%- serializable.name %>")
          <% } else if (!serializable.hasAssociatedValues) { %>
            guard let rawValue = String(meowValue) else {
                return nil
            }

            switch rawValue {
              <% serializable.cases.forEach(enumCase => {
                %> case "<%- enumCase.name %>": self = .<%- enumCase.name %>
              <%})%>
              default: throw Meow.Error.enumCaseNotFound(enum: "<%- serializable.name %>", name: rawValue)
            }
          <% } else { %>
            <# error: enum <%- serializable.name %> has associated values. associated values are not yet supported by Meow. #>
          <% } %>
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
          return self.meowSerialize()
        }

        func meowSerialize() -> Primitive {
          <% if (serializable.typeName) { %>
            return self.rawValue
          <% } else { %>
            switch self {
              <% serializable.cases.forEach(enumCase => {
                %> case .<%- enumCase.name %>: return "<%- enumCase.name %>"
              <%})%>
            }
          <% } %>
        }

        struct VirtualInstance {
          /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
          static func ==(lhs: VirtualInstance, rhs: <%- serializable.name %>?) -> Query {
            return lhs.keyPrefix == rhs?.meowSerialize()
          }

          var keyPrefix: String

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        }
      }
    <% } else { %>
      // Struct or Class extension
      extension <%- serializable.name %> : ConcreteSerializable {
      <% if (serializable.kind == "class") { %>// sourcery:inline:auto:<%- serializable.name %><% } %>
      init(meowDocument source: Document) throws {
          <% if (serializable.based["Model"]) { %>self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")<% } %>
        <% serializable.variables.forEach(variable => {
            if(variable.isComputed) { return; }%>
          self.<%- variable.name %> =<% deserializeFromPrimitive(variable.name, variable.type, variable.typeName, `source["${variable.name}"]`);
        }); %>

        <% if (serializable.based["Model"]) { %>Meow.pool.pool(self)<% } %>
      }
      <% if (serializable.kind == "class") { %>
        <% if (serializable.based["Model"]) { %>var _id = ObjectId()<% } %>
        // sourcery:end
      <% } %>


        <% if (serializable.kind == "class") { %>convenience<% } %> init?(meowValue: Primitive?) throws {
          guard let document = Document(meowValue) else {
            return nil
          }
          try self.init(meowDocument: document)
        }

        func meowSerialize() -> Document {
          var document = Document()
            <% if (serializable.based["Model"]) { %>document["_id"] = self._id<% } %>
          <% serializable.allVariables.forEach(variable => {
              if(variable.isComputed) { return; }%>
            document["<%- variable.name %>"] =<% serializeToPrimitive("self." + variable.name, variable.type, variable.typeName);
          });%>
          return document
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Document {
          // TODO: re-evaluate references
            return self.meowSerialize()
        }

        struct VirtualInstance {
          var keyPrefix: String

          <% serializable.allVariables.forEach(variable => {
              if(variable.isComputed) { return; } %>
             /// <%- variable.name %>: <%- variable.typeName.name %>
             <%
             if (supportedPrimitives.includes(variable.unwrappedTypeName)) {
               if (numberTypes.includes(variable.unwrappedTypeName)) {
                 %> var <%- variable.name %>: VirtualNumber { return VirtualNumber(name: keyPrefix + "<%- variable.name %>") } <%
               } else {
                 %> var <%- variable.name %>: Virtual<%- variable.unwrappedTypeName %> { return Virtual<%-variable.unwrappedTypeName%>(name: keyPrefix + "<%-variable.name%>") } <%
               }
             } else if ((variable.type && variable.type.kind == "enum") || serializables.includes(variable.type)) {
               ensureSerializable(variable.type);
               %> var <%- variable.name %>: <%- variable.unwrappedTypeName %>.VirtualInstance { return <%-variable.unwrappedTypeName%>.VirtualInstance(keyPrefix: keyPrefix + "<%-variable.name%>") } <%
             }
          }) %>

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        } // end VirtualInstance

        enum Key : String {-%>
            case _id
          <% serializable.allVariables.forEach(variable => {
              if(variable.isComputed) { return; }%>
            case <%- variable.name %>-%>
          <%})%>


        }

      } // end struct or class extension of <%- serializable.name %>
  <%
      if (serializable.based["Model"]) { %>
        extension <%- serializable.name %> : ConcreteModel {
          static let meowCollection: MongoKitten.Collection = Meow.database["<%- serializable.name.toLowerCase() %>"]
          var meowReferencesWithValue: ReferenceValues { return [] }

          static func find(_ closure: ((VirtualInstance) -> (Query))) throws -> CollectionSlice<<%- serializable.name %>> {
            let query = closure(VirtualInstance())
            return try self.find(query)
          }

          static func findOne(_ closure: ((VirtualInstance) -> (Query))) throws -> <%- serializable.name %>? {
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
      <% }
    }
    %>
    func meowReinstantiate<%- serializable.name %>Array(from source: Primitive?) throws -> [<%- serializable.name %>]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> <%- serializable.name %> in
            return try Meow.Helpers.requireValue(<%- serializable.name %>(meowValue: rawValue), keyForError: "index \(index) on array of <%- serializable.name %>")
        }
    }
  <%
  } // end struct/class serializable loop

  let tupleIndex = 0;
  while (serializableTuples.length > generatedSerializableTuples.length) {
    let tupleName = serializableTuples[tupleIndex];
    let tuple = tupleName.tuple;
    tupleIndex++;
    generatedSerializableTuples.push(tuple);

    %>
    func <%- makeTupleSerializeFunctionName(tuple); %>(_ tuple: <%- tupleName.unwrappedTypeName %>?) -> Document? {
      guard let tuple = tuple else {
        return nil
      }

      return [
        <% tuple.elements.forEach(element => { %>
          "<%- element.name %>": tuple.<%- element.name %>,-%>
        <% }) %>
      ]
    }

    func <%- makeTupleDeserializeFunctionName(tuple); %>(_ primitive: Primitive?) throws -> <%- tupleName.unwrappedTypeName %>? {
      guard let document = Document(primitive) else {
        return nil
      }

      return (-%>
        <% tuple.elements.forEach((element, index) => { %>
          <% /* /^\d+$/ checks if the element name has only numbers in it */ %> -%>
          <% if (! /^\d+$/.test(element.name)) { %> <%- element.name %>: <% } %> -%>
          <%- deserializeFromPrimitive("tuple element " + element.name, element.type, element.typeName, `document["${element.name}"]`) %>-%>
          <% if (index < tuple.elements.length-1) { %>,<% } %> -%>
        <% }) %>
      )
    }
    <%

  } // end tuple loop

} // end generatedSerializables

// three times for types that are discovered during the tuple generation process
generateSerializables()
generateSerializables()
generateSerializables()
%>
// Serializables parsed: <%- serializables.map(s => s.name) %>
// Tuples parsed: <%- serializableTuples.map(s => makeTupleSignature(s)) %>
