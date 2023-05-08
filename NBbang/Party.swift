import Foundation
import RealmSwift

class Party: Object {
    
    @objc dynamic var name:String?
    var user = List<User>()
    var place = List<Place>()
    @objc dynamic var totalPrice: Int = 0
    
    
    convenience init(name: String? = nil) {
        self.init()
        self.name = name
    }
    
    func addUser(id: String?, name: String?, phone: String?, account: String?) {
        user.append(User(id: id, name: name, phone: phone, account: account))
    }
    func addPlace(name: String?, price: Int) {
        place.append(Place(name: name, price: price))
    }
    func plusPrice(price: Int) {
        totalPrice += price
    }
}
