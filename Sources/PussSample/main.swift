import Puss
import Foundation

let server = try! Server(hostname: "127.0.0.1")
let db = server["puss"]

Puss.init(db)

