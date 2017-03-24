import Foundation
import Meow
import MeowVapor
import Vapor

<%
    // helper
    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    let supportedPrimitives = ["ObjectId", "String", "Int", "Int32", "Bool", "Document", "Double", "Data", "Binary", "Date", "RegularExpression"];
    let supportedReturnTypes = ["JSONObject", "JSONArray", "JSON", "Response", "ResponseRepresentable"];
    let models = (types.based["Model"] || []);

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
    
    func integrate(with droplet: Droplet) {
    <% model.allMethods.forEach(method => {
        let basicReturnType = supportedReturnTypes.includes(method.unwrappedReturnTypeName);

        if(!basicReturnType || method.returnType.based.ResponseRepresentable) {
            return;
        }

        // TODO: Call method appropriately
            %>
    <%});%>
    }
}
<%
    }
%>
