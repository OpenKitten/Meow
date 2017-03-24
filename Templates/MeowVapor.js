import Foundation
import Meow
import MeowVapor
import Vapor

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

    let supportedPrimitives = ["ObjectId", "String", "Int", "Int32", "Bool", "Document", "Double", "Data", "Binary", "Date", "RegularExpression"];
    let supportedReturnTypes = ["JSONObject", "JSONArray", "JSON", "Response", "ResponseRepresentable"];
    let models = (types.based["Model"] || []);
    let exposedMethods = {};

    let generatedModels = [];
    let modelIndex = 0;

    while(models.length > generatedModels.length) {
        let model = models[modelIndex];
        modelIndex++;
        generatedModels.push(model);
        
%>
extension <%- model.name %> : StringInitializable {
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
    model.allMethods.forEach(method => {
        let basicReturnType = supportedReturnTypes.includes(method.unwrappedReturnTypeName);
        let permissions = method.annotations["permissions"];

        if((!basicReturnType && !method.returnType.based.ResponseRepresentable && !method.isInitializer) || !permissions) {
            return;
        }

        // Create/POST
        if(method.isInitializer) {%>
        droplet.post("<%-plural(model.name.toLowerCase())%>") { request in
            return "";
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
}<% } %>

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