import Foundation
import Meow
import MeowVapor
import Vapor
import Cheetah
import HTTP

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
let modelIndex = 0;

while(models.length > generatedModels.length) {
    let model = models[modelIndex];
    modelIndex++;
    generatedModels.push(model);
%>
extension <%- model.name %> : StringInitializable, ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSONObject().makeResponse()
    }

    public func makeJSONObject() -> JSONObject {
        var object: JSONObject = [
            "id": self._id.hexString
        ]
        <%model.allVariables.forEach(variable => {
            if(!variable.annotations["public"] || variable.isStatic) {
                return;
            }
            %>
        object["<%-variable.name%>"] = self.<%-variable.name%>
        <%});-%>

        return object
    }

    public convenience init?(from string: String) throws {
        let objectId = try ObjectId(string)

        guard let selfDocument = try <%- model.name %>.meowCollection.findOne("_id" == objectId) else {
            return nil
        }

        try self.init(meowDocument: selfDocument)
    }<%

    model.variables.forEach(variable => {
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
      drop.get("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init) { request, subject in
        return subject
      }

      drop.delete("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init) { request, subject in
        try subject.delete()

        return subject
      }
<%
    let methods = [];
    let hasInitializer = false;

    model.allMethods.forEach(method => {
        let basicReturnType = supportedReturnTypes.includes(method.unwrappedReturnTypeName);
        let httpMethod;
        let parametersText = undefined;

        if(!basicReturnType && !method.returnType.based["ResponseRepresentable"] && !method.isInitializer) {
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
            let parametersText = undefined;
            httpMethod = "post";
        } else {
            if(!httpMethod) { return; }
        }
        -%>
        <%_ if(method.isStatic || method.isInitializer) { %>
        droplet.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>") { request in
        <%_} else { %>
        <%-method.returnType%>
        droplet.<%-httpMethod%>("<%-plural(model.name.toLowerCase())%>", <%-model.name%>.init, "<%-method.shortName%>") { request, subject in
        <%_}

        if(method.parameters.length > 0) {-%>
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

                  if(enumMapping == "String" || enumMapping == parameter.type.rawType.name) {%>
            guard let otherValue = <%-enumMapping%>(object["<%-parameter.name%>"]) else {
                throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
            }

            let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: otherValue)
                  <%_ } else if(enumMapping) { -%>
            let <%-parameter.name%>JSON = <%-enumMapping%>(object["<%-parameter.name%>"]))

            guard let otherValue = <%-enumMapping%>(<%-parameter.name%>JSON) else {
                throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
            }

            let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: otherValue)
                  <%_
                  }
                }

                if(parametersText == undefined || parametersText == null) {
                    parametersText = parameterText;
                } else {
                    parametersText += ", " + parameterText;
                }
              // Parse parameter keys and types and query the JSONObject for a key that can be converted to this type
              });
            }
            if(method.isStatic || method.isInitializer) { _%>
            let subject = <%-model.name%>.<%-method.shortName%>(<%-parametersText ? parametersText : ""%>)
            <% if(method.isInitializer){ %>try subject.save()
            let jsonResponse = subject.makeJSONObject()

            return Response(status: .created, headers: [
                "Content-Type": "application/json; charset=utf-8"
            ], body: Body(jsonResponse.serialize()))<%_ } else { _%>
            return subject<% } %>
            <%_ } else { -%>
            return subject.<%-method.shortName%>(<%-parametersText ? parametersText : ""%>)
            <%_ } -%>
        }<%
        methods.push(method);
        exposedMethods.push(`${model.name}_${method.shortName}`);
    });
    %>
    }
}
<% } -%>

extension Meow {
    public static func integrate(with droplet: Droplet) {<%
        modelIndex = 0;
        while(modelIndex < generatedModels.length) {
            let model = generatedModels[modelIndex];
            modelIndex++; %>
        <%-model.name%>.integrate(with: droplet)<% } %>
    }
}

<%
if(exposedMethods.length > 0) {
  let methodPosition = 0;-%>
public enum ExposedMethods : String {<%
  while(methodPosition < exposedMethods.length) {
    let methodName = exposedMethods[methodPosition];
    methodPosition++;%>
    case <%-methodName%><%
  }
%>
}
<%}-%>
