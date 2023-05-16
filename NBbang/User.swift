import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var money: Int = 0
    @objc dynamic var phone: String?
    @objc dynamic var account: String?
    @objc dynamic var member: Int = 0
    
    let parties = LinkingObjects(fromType: Party.self, property: "user")
    let places = LinkingObjects(fromType: Place.self, property: "enjoyer")
    let menus = LinkingObjects(fromType: Menu.self, property: "enjoyer")
    
    convenience init(id: String? = nil, name: String? = nil, phone: String? = nil, account: String? = nil) {
        self.init()
        self.id = id
        self.name = name
        self.phone = phone
        self.account = account
    }

}
