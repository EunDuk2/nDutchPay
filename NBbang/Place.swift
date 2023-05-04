import Foundation
import RealmSwift

class Place: Object {
    
    @objc dynamic var name:String?
    var enjoyer = List<User>()
    @objc dynamic var price:Int = 0
    
    convenience init(name: String? = nil, price: Int = 0) {
        self.init()
        self.name = name
        self.price = price
    }
    
//    func addEnjoyer(id: String?, name: String?, phone: String?, account: String?) {
//        enjoyer.append(User(id: id, name: name, phone: phone, account: account))
//    }
    func addEnjoyer(user:User) {
        enjoyer.append(user)
    }
}
