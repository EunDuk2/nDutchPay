import Foundation
import RealmSwift

class Place: Object {
    
    @objc dynamic var name:String?
    var enjoyer = List<User>()
    @objc dynamic var price:String?
    
    convenience init(name: String? = nil) {
        self.init()
        self.name = name
    }
    
    func addEnjoyer(id: String?, name: String?, phone: String?, account: String?) {
        enjoyer.append(User(id: id, name: name, phone: phone, account: account))
    }
}
