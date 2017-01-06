import Puss
import Foundation

do {
    
    let server = try Server(hostname: "127.0.0.1")
    let db = server["puss"]
    try db.drop()
    
    Puss.init(db)
    
    let boss = try User(email: "harriebob@example.com")
    boss.firstName = "Harriebob"
    boss.lastName = "Konijn"
    try boss.save()
    
    let bossHouse = House()
    bossHouse.owner = Reference(boss)
    try bossHouse.save()
    
    try bossHouse.delete()
} catch {
    print("Whoops, \(error)")
}
