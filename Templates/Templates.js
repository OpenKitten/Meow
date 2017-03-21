import Foundation
import Meow

<%
/**
Generates code for deserializing a value from a document

@param {string} name - The name of the value to look up in the document
@param {object} type - The type (e.g. variable.type), if available - required for nonprimitive values, may be null or undefined for primitives
@param {object} typeName - The typeName (required, e.g. variable.typeName)
@param {string} documentName - The local name of the variable in which the source document is stored
*/
function deserializeFromDocument(name, type, typeName, documentName) {
  if (supportedPrimitives.includes(typeName.unwrappedTypeName)) {
    if (typeName.isOptional) {
      %> <%- typeName.unwrappedTypeName %>(source["<%-name%>"]) <%
    } else {
      %> try Meow.Helpers.requireValue(<%-typeName.name%>(source["<%-name%>"]), keyForError: "<%-name%>") <%
    }
  } else if (type) {
    // Embed a custom type
    ensureSerializable(type);

    if (typeName.isOptional) {
      %> try <%-typeName.unwrappedTypeName-%>(meowValue: source["<%-name%>"]) <%
    } else {
      %> try Meow.Helpers.requireValue(<%-typeName.unwrappedTypeName-%>(meowValue: source["<%-name%>"]), keyForError: "<%-name%>") <%
    }
  } else if (typeName.isArray) {
    let elementTypeNameString = typeName.name.substring(1, typeName.name.length - (typeName.isOptional ? 2 : 1)); // workaround for sourcery bug
    let elementType = types.all.find(t => t.name == elementTypeNameString);
    ensureSerializable(elementType);

    if (typeName.isOptional) {
      %> try meowReinstantiate<%- elementTypeNameString %>Array(from: source["<%-name%>"]) <%
    } else {
      %> try Meow.Helpers.requireValue(meowReinstantiate<%- elementTypeNameString %>Array(from: source["<%-name%>"]), keyForError: "<%-name%>") <%
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
    let elementTypeNameString = typeName.name.substring(1, typeName.name.length - (typeName.isOptional ? 2 : 1)); // workaround for sourcery bug
    let elementType = types.all.find(t => t.name == elementTypeNameString);
    ensureSerializable(elementType);
    // ensureSerializable(types.all[elementTypeNameString]);
    %> <%- accessor %><%- typeName.isOptional ? '?' : '';%>.map { $0.meowSerialize() } <%
    %> // parsed element string: <%- elementTypeNameString  %> <%
  }
}

/**
Ensures the given type is serializable. If it is not already, it will be added to the serialization code generation queue.

@param {object} type - The type object (e.g. variable.type)
*/
function ensureSerializable(type) {
  // check if it is already in the queue, and if it is, return:
  if (serializables.find(t => t.name == type.name)) { return };
  serializables.push(type);
}

// Selects all classes and structs that are either based on a model or embeddable protocol
let models = (types.based["Model"] || []);
let embeddables = (types.based["Embeddable"] || []);

// An array containing all serializable types
// Additional types may be added below, in the template itself (supporting implicit serializables)
let serializables = models.concat(embeddables);

let supportedPrimitives = ["ObjectId", "String", "Int", "Int32", "Bool", "Document", "Double", "Data", "Binary", "Date", "RegularExpression"];

supportedPrimitives.forEach(primitive => { %>

  extension Array where Element == <%- primitive -%> {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(<%- primitive -%>(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }
<% }) // end supportedPrimitives loop

// Generate serialization for every serializable
// It is important to keep this as far down as possible.
// Keep track of the serializables we already handled:
let generatedSerializables = [];

// The reason for looping this way is that embedded serializables may be recursive, so implicit serializables may be added while looping
let serializableIndex = 0;
while (serializables.length > generatedSerializables.length) {
  let serializable = serializables[serializableIndex];
  serializableIndex++;
  generatedSerializables.push(serializable);

  if (serializable.kind == "enum") {
    if (!serializable.rawTypeName) { %>
        <#enum <%- serializable.name %> has no raw type#>
        <#To fix this error, add a BSON primitive type (such as String) as raw type to your enum#>
      <%
      continue;
    } else if (!supportedPrimitives.includes(serializable.rawTypeName.name)) { %>
      <#enum <%- serializable.name %> has an unsupported raw type#>
      <#To fix this error, add a BSON primitive type (such as String) as raw type to your enum#>
    <%
      continue;
    } %>

    // Enum extension
    extension <%- serializable.name %> : ConcreteSingleValueSerializable {
      /// Creates a `<%- serializable.name %>` from a BSON Primtive
      init(meowValue: Primitive?) throws {
        let rawValue = try Meow.Helpers.requireValue(<%- serializable.rawTypeName.name %>(meowValue), keyForError: "enum <%- serializable.name %>")
        self = try Meow.Helpers.requireValue(<%- serializable.name %>(rawValue: rawValue), keyForError: "enum <%- serializable.name %>")
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
        return self.meowSerialize()
      }

      func meowSerialize() -> Primitive {
        return self.rawValue
      }
    }
  <% } else { %>
    // Struct or Class extension
    extension <%- serializable.name %> : ConcreteSerializable {
    // sourcery:inline:<%- serializable.name %>.Meow
    init(meowDocument source: Document) throws {-%>
      <% serializable.variables.forEach(variable => { %>
        self.<%- variable.name %> =<% deserializeFromDocument(variable.name, variable.type, variable.typeName, "source");
      }); %>
    }
    // sourcery:end

      <% if (serializable.kind == "class") { %>convenience<% } %> init(meowValue: Primitive?) throws {
        let document = try Meow.Helpers.requireValue(Document(meowValue), keyForError: "document for <%- serializable.name %>")
        try self.init(meowDocument: document)
      }

      func meowSerialize() -> Document {
        var document = Document()
        <% serializable.variables.forEach(variable => { %>
          document["<%- variable.name %>"] =<% serializeToPrimitive("self." + variable.name, variable.type, variable.typeName);
        });%>
        return document
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Document {
        // TODO: re-evaluate references
          return self.meowSerialize()
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

        struct VirtualInstance {
          var keyPrefix: String

          // TODO: Add properties

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        }
      }
    <% }
  }
  %>
  func meowReinstantiate<%- serializable.name %>Array(from source: Primitive?) throws -> [<%- serializable.name %>]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { _, rawValue -> <%- serializable.name %> in
          return try <%- serializable.name %>(meowValue: rawValue)
      }
  }
<%
} // end serializables loop

%>
// Serializables parsed: <%- serializables.map(s => s.name) %>
