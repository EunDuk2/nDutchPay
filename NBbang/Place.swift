import Foundation
import RealmSwift

class Place: Object {
    
    @objc dynamic var name:String?
    var enjoyer = List<User>()
    var menu = List<Menu>()
    @objc dynamic var defaultMenu: Menu?
    @objc dynamic var totalPrice:Int = 0
    @objc dynamic var imageData: Data?
    
    convenience init(name: String? = nil, totalPrice: Int = 0) {
        self.init()
        self.name = name
        self.totalPrice = totalPrice
    }
    
    func setDefaultMenu(defaultMenu: Menu) {
        self.defaultMenu = defaultMenu
    }
    func addEnjoyer(user:User) {
        enjoyer.append(user)
    }
    func addMenu(name: String? = nil, price: Int=0, count: Int=0, enjoyer: List<User>?=nil){
        menu.append(Menu(name: name, price: price, count: count, enjoyer: enjoyer))
    }
    func plusPrice(price:Int) {
        totalPrice += price
    }
    func minusDmenuPrice(price:Int) {
        defaultMenu?.totalPrice -= price
    }
}
