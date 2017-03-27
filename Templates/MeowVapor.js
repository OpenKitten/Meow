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

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

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
let supportedReturnTypes = ["JSONObject", "JSONArray", "JSON", "Response", "ResponseRepresentable"];
let bsonJsonMap = {
    "Int": "Int",
    "Int32": "Int",
    "Bool": "Bool",
    "Double": "Double",
    "String": "String",
    "ObjectId": "String",
    "RegularExpression": "String"
};
let exposedMethods = {};

let generatedModels = [];
let modelIndex = 0;

while(models.length > generatedModels.length) {
    let model = models[modelIndex];
    modelIndex++;
    generatedModels.push(model);
%>
extension <%- model.name %> : StringInitializable, ResponseRepresentable {
    public func makeResponse() throws -> Response {
        var object: JSONObject = [
            "id": self._id.hexString
        ]
        <%model.variables.forEach(variable => {
            if(!variable.annotations["public"]) {
                return;
            }
            %>
        object["<%-variable.name%>"] = self.<%-variable.name%>
        <%});-%>

        return try object.makeResponse()
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

    fileprivate static func integrate(with droplet: Droplet, prefixed prefix: String = "/") {<%

    let methods = [];
    let hasInitializer = false;

    model.allMethods.forEach(method => {
        let basicReturnType = supportedReturnTypes.includes(method.unwrappedReturnTypeName);
        let permissions = method.annotations["permissions"];

        if((!basicReturnType && !method.returnType.based.ResponseRepresentable && !method.isInitializer) || !permissions) {
            return;
        }

        // Create/POST
        if(method.isInitializer && !hasInitializer) {
            hasInitializer = true;
            let parametersText = undefined;
        %>
        droplet.post("<%-plural(model.name.toLowerCase())%>") { request in<%
            if(method.parameters.length > 0) {%>
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
                      <% } else if(enumMapping) { -%>
            let <%-parameter.name%>JSON = <%-enumMapping%>(object["<%-parameter.name%>"]))

            guard let otherValue = <%-enumMapping%>(<%-parameter.name%>JSON) else {
                throw Abort(.badRequest, reason: "Invalid key \"<%-parameter.name%>\"")
            }

            let <%-parameter.name%> = try <%-parameter.unwrappedTypeName%>(meowValue: otherValue)
                      <%
                      }
                    }

                    if(parametersText == undefined || parametersText == null) {
                        parametersText = parameterText;
                    } else {
                        parametersText += ", " + parameterText;
                    }
                // Parse parameter keys and types and query the JSONObject for a key that can be converted to this type
                });
            }-%>

            let <%-model.name.toLowerCase()%> = <%-model.name%>(<%-parametersText ? parametersText : ""%>)

            try user.save()

            return <%-model.name.toLowerCase()%>
        }
        <% } else if(method.isStatic) {
            // Find/Factory Create (GET, POST)
        } else {
            // Update/Delete (PUT, PATCH, DELETE)
            // Needs an instance
        }

        methods.push(method);
    });
    %>
    }
}
<% } %>

extension Meow {
    public static func integrate(with droplet: Droplet) {<%
        modelIndex = 0;
        while(modelIndex < generatedModels.length) {
            let model = generatedModels[modelIndex];
            modelIndex++; %>
        <%-model.name%>.integrate(with: droplet)<% } %>
    }
}

<% if(Object.size(exposedMethods) > 0) { %>
public enum ExposedMethods : String {
    <%
    function makeMethodSignature(method) {
        return method.parameters.map(p => ((p.name || "") + p.unwrappedTypeName)).join("And");
    }

    function makeExposedMethodName(typeName, method) {
        return "exposedAPIMethod" + makeMethodSignature(method) + "For" + typeName;
    }

    let key;

    for(key in exposedMethods) {
        if(!exposedMethods.hasOwnProperty(key)) {
            continue;
        }

        let methodPosition = 0;
        let methods = exposedMethods[key];

        while(methodPosition < methods.length) {
            %>case <%-key%> = "<%-makeExposedMethodName(key, methods[methodPosition])%>"
            <%
        }
    }
%>
}
<%}%>
