import Foundation
import RealmSwift

class Menu: Object {
    
    @objc dynamic var name: String?
    @objc dynamic var price: Int = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var totalPrice: Int = 0
    var enjoyer = List<User>()
    
    convenience init(name: String? = nil, price: Int, count: Int, enjoyer: List<User>?=nil) {
        self.init()
        self.name = name
        self.price = price
        self.count = count
        self.totalPrice = price * count
        if let enjoyers = enjoyer {
            self.enjoyer = enjoyer!
        }
    }
    
    func addEnjoyer(user:User) {
        enjoyer.append(user)
    }
}
