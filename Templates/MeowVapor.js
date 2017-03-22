import Foundation
import Meow
import MeowVapor

<% let accessLevelType = types.enums.find(t => t.name == "AccessLevel"); %>
<% if (accessLevelType == undefined) {%>
    enum AccessLevel {
      case anonymous
    }
<% } %>
