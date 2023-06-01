import Foundation
import RealmSwift

class Party: Object {
    
    @objc dynamic var name:String?
    var user = List<User>()
    var place = List<Place>()
    @objc dynamic var totalPrice: Int = 0
    var account = List<String>()
    
    
    convenience init(name: String? = nil) {
        self.init()
        self.name = name
    }
    
    func addUser(id: String?, name: String?, phone: String?="", account: String?="") {
        user.append(User(id: id, name: name, phone: phone, account: account))
    }
    func addUser(user:User?) {
        self.user.append(user!)
    }
    func addPlace(name: String?, totalPrice: Int) {
        place.append(Place(name: name, totalPrice: totalPrice))
    }
    func addAccount(account: String) {
        self.account.append(account)
    }
    func plusPrice(price: Int) {
        totalPrice += price
    }
    func minusPrice(price: Int) {
        totalPrice -= price
    }
}
