import Foundation
import Meow
import MeowVapor
import Vapor
import Cheetah
import HTTP
import Cheetah
import ExtendedJSON

<%
// helpers
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function plural(name) {
    let lastLetter = name.slice(-1);
    name = name.substring(0, name.length - 1);

    if(lastLetter == "y") {
        return name + "ies";
    } else if(lastLetter == "o") {
        return name + "oes";
    } else {
        return name + lastLetter + "s"
    }
}

let supportedJSONValues = ["JSONObject", "JSONArray", "String", "Int", "Double", "Bool"];
let specialTypes = ["File"];

// TODO: Return (other) models and embeddables
// TODO: Return many models/embeddables
// TODO: Return tuples
// TODO: Return file
let supportedReturnTypes = ["JSONObject", "JSONArray", "String", "JSON", "Response", "ResponseRepresentable"];
let bsonJsonMap = {
    "Int": "Int",
    "Int32": "Int",
    "Bool": "Bool",
    "Double": "Double",
    "String": "String",
    "ObjectId": "String",
    "RegularExpression": "String"
};
let exposedMethods = [];
let generatedModels = [];
let authenticables = [];
let modelIndex = 0;

serializables.forEach(serializable => {
  if(serializable.annotations["user"] && models.includes(serializable)) {
    authenticables.push(serializable.name); -%>
extension <%-serializable.name %> : Authenticatable {
    public static func resolve(byId identifier: ObjectId) throws -> <%-serializable.name%>? {
        guard let document = try <%-serializable.name%>.meowCollection.findOne("_id" == identifier) else {
            return nil
        }

        return try Meow.pool.instantiateIfNeeded(type: <%-serializable.name%>.self, document: document)
    }
}
<%}

  if(serializable.kind == "enum") {%>
extension <%- serializable.name %> {
    public init(jsonValue: Cheetah.Value?) throws {
    <% if (serializable.typeName) { %>
        let rawValue = try Meow.Helpers.requireValue(<%- serializable.rawTypeName.name %>(jsonValue), keyForError: "enum <%- serializable.name %>")
        self = try Meow.Helpers.requireValue(<%- serializable.name %>(rawValue: rawValue), keyForError: "enum <%- serializable.name %>")
    <% } else if (!serializable.hasAssociatedValues) { %>
        let rawValue = try Meow.Helpers.requireValue(String(jsonValue), keyForError: "enum <%- serializable.name %>")
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
}
<%_ } else { -%>
extension <%- serializable.name %> {
    public <%-serializable.kind == "class" ? "convenience " : ""%>init(jsonValue: Cheetah.Value?) throws {
        let document = try Meow.Helpers.requireValue(Document(jsonValue), keyForError: "")

        try self.init(document: document)
    }
}
<% } -%>
extension <%- serializable.name %> {
  public func makeJSONObject() -> JSONObject {
    <%_
    let type = (serializable.allVariables.length > 0) ? "var" : "let";
    if(models.includes(serializable)) { -%>
      <%-type%> object: JSONObject = [
          "id": self._id.hexString
      ]
    <%_ } else { -%>
      <%-type%> object: JSONObject = [:]
    <%_ } -%>

      <%_ serializable.variables.forEach(variable => {
          if(!variable.annotations["public"] || variable.isStatic || variable.typeName.unwrappedTypeName.startsWith("File<")) {
              return;
          }

          if(supportedJSONValues.includes(variable.typeName.unwrappedTypeName)) {-%>
      object["<%-variable.name%>"] = self.<%-variable.name%>
          <%_ } else if(serializables.includes(variable.type)) {
            if(variable.type.kind == "enum") { -%>
      object["<%-variable.name%>"] = self.<%-variable.name%><%-variable.isOptional ? "?" : ""%>. fialize() as? Cheetah.Value
          <%_ } else { -%>
      object["<%-variable.name%>"] = self.<%-variable.name%><%-variable.isOptional ? "?" : ""%>.makeJSONObject()
          <%_ }
          } else if(bsonJsonMap[variable.type.name]) { -%>
      object["<%-variable.name%>"] = <%-bsonJsonMap[variable.type.name]%>(self.<%-variable.name%>)
          <% } -%>
      <%_ }); -%>

      return object
  }
}

<%});

while(models.length > generatedModels.length) {
    let model = models[modelIndex];
    modelIndex++;
    generatedModels.push(model);
%>
extension <%- model.name %> : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSONObject().makeResponse()
    }

    public convenience init?(from string: String) throws {
        let objectId = try ObjectId(string)

        guard let selfDocument = try <%- model.name %>.meowCollection.findOne("_id" == objectId) else {
            return nil
        }

        try self.init(document: selfDocument)
    }<%

    model.variables.forEach(variable => {
      if(variable.isComputed) { return; }
      let primitive = supportedPrimitives.includes(variable.typeName.unwrappedTypeName);

      if((!variable.isEnum && !primitive) || !variable.annotations["unique"]) {
          return;
      }
    %>

    public static func by<%-capitalizeFirstLetter(variable.name)%>(_ string: String) throws -> <%-model.name%>? {
        let value = <%-primitive ? "" : "try" %> <%-variable.typeName.unwrappedTypeName%>(<%- primitive ? "" : "meowValue: " %>string as Primitive?)

        return try <%-model.name%>.findOne { model in
           return model.<%-variable.name%> == value
        }
    }<% }); %>

    fileprivate static func integrate(with droplet: Droplet, prefixed prefix: String = "/") {
        <%_  let group = "droplet";
            if(model.annotations["group"]) {
                group = "group";%>
        let group = droplet.grouped("<%-model.annotations["group"]%>")

            <%_ } -%>
        <%-group%>.get("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init) { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_get(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_get(subject)) { request in
                    return subject
                }
            }
        }

        <%-group%>.delete("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init) { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_delete(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_delete(subject)) { request in
                    try subject.delete()
                    return Response(status: .ok)
                }
            }
        }<%

    exposedMethods.push(`${model.name}_get(${model.name})`);
    exposedMethods.push(`${model.name}_delete(${model.name})`);

    let methods = [];
    let hasInitializer = false;

    model.allVariables.forEach(variable => {
      if(!variable.annotations["public"] || variable.isStatic) { return; }

      if(variable.typeName.unwrappedTypeName.startsWith("File<")) {
        let path;

        if(variable.annotations["path"]) {
          path = variable.annotations["path"];
        } else {
          path = variable.name.toLowerCase();
        } %>

        <%-group%>.get("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init, "<%-path%>") { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_download_<%-variable.name%>(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_download_<%-variable.name%>(subject)) { request in
                    return try subject.<%-variable.name%>.makeResponse()
                }
            }
        }

        <%-group%>.post("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init, "<%-path%>") { request, subject in
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_upload_<%-variable.name%>(subject)) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.<%-model.name%>_upload_<%-variable.name%>(subject)) { request in
                    subject.<%-variable.name%> = try <%-variable.typeName.unwrappedTypeName%>.store(Data(request.body.bytes ?? []))
                    try subject.save()
                    return Response(status: .ok)
                }
            }
        }<%
        exposedMethods.push(`${model.name}_download_${variable.name}(${model.name})`);
        exposedMethods.push(`${model.name}_upload_${variable.name}(${model.name})`);
      }
    });

    model.allMethods.forEach(method => {
        let basicReturnType = supportedReturnTypes.includes(method.unwrappedReturnTypeName);
        let httpMethod;
        let parametersText = undefined;

        if(!basicReturnType && !method.isInitializer && !serializables.includes(method.returnType) && (!method.returnType || !method.returnType.based["ResponseRepresentable"])) {
            return;
        }

        httpMethod = method.annotations["method"];

        if(httpMethod) {
            httpMethod = httpMethod.toLowerCase();
            if(!["get", "put", "post", "delete", "patch"].includes(httpMethod)) {
                return;
            }
        }

        // Create/POST
        if(method.isInitializer) {
            if(hasInitializer) { return; }

            hasInitializer = true;
            parametersText = undefined;
            httpMethod = "post";
        } else {
            if(!httpMethod) { return; }
        }

        let routeName;

        if(method.isInitializer) {
          routeName = `${model.name}_init`;
        } else if(method.isStatic) {
          routeName = `${model.name}_static_${method.shortName}`;
        } else {
            routeName = `${model.name}_${method.shortName}`;
        }
        %>
        <%_ if(method.annotations["path"]) { %>
        <%-group%>.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>", <% if(!method.isStatic){%><%-model.name%>.init, <%}%>"<%-method.annotations["path"]%>") { request in
        <%_ } else if(method.isInitializer) { %>
        <%-group%>.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>") { request in
        <%_ } else if(method.isStatic) { %>
        <%-group%>.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>", "<%-method.shortName%>") { request in
        <%_ } else { %>
        <%-method.returnType%>
        <%-group%>.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init, "<%-method.shortName%>") { request, subject in
        <%_} -%>
            return try AuthenticationMiddleware.default.respond(to: request, route: MeowRoutes.<%-routeName%>) { request in
                return try AuthorizationMiddleware.default.respond(to: request, route: MeowRoutes.<%-routeName%>) { request in
        <%_ if(method.parameters.length > 0) {-%>
                    guard let object = request.jsonObject else {
                        throw Abort(.badRequest, reason: "No JSON object provided")
                    }
            <%
            method.parameters.forEach(parameter => {
                let parameterText = parameter.name + ": " + parameter.name;
                let basicMapping = bsonJsonMap[parameter.unwrappedTypeName];

                if(basicMapping && basicMapping == parameter.unwrappedTypeName) {%>
                    guard let <%-parameter.name%> = <%-parameter.unwrappedTypeName%>(object["<%-parameter.name%>"]) else {
                        throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
                    }
                <% } else if(basicMapping) {%>
                    let <%-parameter.name%>JSON = <%-basicMapping%>(object["<%-parameter.name%>"]))

                    guard let <%-parameter.name%> = <%-parameter.unwrappedTypeName%>(<%-parameter.name%>JSON as Primitive?) else {
                        throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
                    }
              <%} else if(parameter.type && serializables.includes(parameter.type) && parameter.type.kind == "enum") {
                  let enumMapping;

                  if(parameter.type.rawType) {
                      enumMapping = bsonJsonMap[parameter.type.rawType.name];
                  } else {
                      enumMapping = "String";
                  }

                  if(enumMapping == "String" || enumMapping == parameter.type.rawType.name) {
                      if(parameter.typeName.isOptional) {%>
                    let <%-parameter.name%>: <%-parameter.typeName.name%>

                    if let <%-parameter.name%>JSON = <%-enumMapping%>(object["<%-parameter.name%>"]) {
                        <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: <%-parameter.name%>JSON)
                    } else {
                        <%-parameter.name%> = nil
                    }
                      <% } else { %>
                    guard let <%-parameter.name%>JSON = <%-enumMapping%>(object["<%-parameter.name%>"]) else {
                        throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
                    }

                    let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: <%-parameter.name%>JSON)
                  <%_
                      }
                    } else if(enumMapping) { -%>
                    let <%-parameter.name%>JSON = <%-enumMapping%>(object["<%-parameter.name%>"]))

                    guard let <%-parameter.name%>JSON = <%-enumMapping%>(<%-parameter.name%>JSON) else {
                        throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
                    }

                    let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: <%-parameter.name%>JSON)
                  <%_ }
                  } else if(serializables.includes(parameter.type)) {
                    if(parameter.typeName.isOptional) {%>
                    let <%-parameter.name%>: <%-parameter.typeName.name%>

                    if let <%-parameter.name%>JSON = object["<%-parameter.name%>"] {
                        <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(jsonValue: <%-parameter.name%>JSON)
                    } else {
                        <%-parameter.name%> = nil
                    }
                    <%_ } else { %>
                    let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(jsonValue: object["<%-parameter.name%>"])
                    <%_ }
                }

                if(parametersText == undefined || parametersText == null) {
                    parametersText = parameterText;
                } else {
                    parametersText += ", " + parameterText;
                }
              // Parse parameter keys and types and query the JSONObject for a key that can be converted to this type
              });
            }
            if(method.isStatic || method.isInitializer) {
              if(method.isInitializer) {
                if(method.isFailableInitializer) {%>
                    guard let subject = try <%-model.name%>.init(<%-parametersText ? parametersText : ""%>) else {
                        // TODO: Replace with JSON Errors
                        throw Abort(.badRequest, reason: "Unknown error")
                    }
                <%_ } else { -%>
                    let subject = try <%-model.name%>.init(<%-parametersText ? parametersText : ""%>)
                        <%_ } -%>
                    try subject.save()
                    let jsonResponse = subject.makeJSONObject()

                    return Response(status: .created, headers: [
                        "Content-Type": "application/json; charset=utf-8"
                    ], body: Body(jsonResponse.serialize()))
              <%_ } else {
                if(method.isOptionalReturnType) { -%>
                    guard let subject = try <%-model.name%>.<%-method.shortName%>(<%-parametersText ? parametersText : ""%>) else {
                        throw Abort(.badRequest, reason: "Unknown error")
                    }

                    return subject
              <%_ } else { -%>
                    return try <%-model.name%>.<%-method.shortName%>(<%-parametersText ? parametersText : ""%>)
              <%_ } -%>
            <%_ } -%>
            <%_ } else { -%>
                    return try subject.<%-method.shortName%>(<%-parametersText ? parametersText : ""%>)
            <%_ } -%>
                }
            }
        }<%
        methods.push(method);
        exposedMethods.push(routeName);
    });%>
    }
}
<% } -%>

extension Meow {
    public static func integrate(with droplet: Droplet) {<%
        modelIndex = 0;

        authenticables.forEach(authenticable => {%>
        AuthenticationMiddleware.default.models.append(<%-authenticable%>.self)
        <%});

        while(modelIndex < generatedModels.length) {
            let model = generatedModels[modelIndex];
            modelIndex++; %>
        <%-model.name%>.integrate(with: droplet)<% } %>
    }
}

<% if(exposedMethods.length > 0) {-%>
enum MeowRoutes {
  <%_ exposedMethods.forEach(method => {-%>
    case <%-method%>
  <%_ }); -%>
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
<%}-%>
