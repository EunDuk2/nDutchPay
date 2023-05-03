import Foundation
import RealmSwift

class Party: Object {
    
    @objc dynamic var name:String?
    var user = List<User>()
    
    convenience init(name: String? = nil) {
        self.init()
        self.name = name
    }
    
    func addUser(id: String?, name: String?, phone: String?, account: String?) {
        user.append(User(id: id, name: name, phone: phone, account: account))
    }
}