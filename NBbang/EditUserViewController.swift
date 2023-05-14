import UIKit
import RealmSwift

class EditUserViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPhone: UITextField!
    
    var index: Int?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        txtInit()
    }
    
    func user() -> Results<User> {
        return realm.objects(User.self)
    }
    
    func txtInit() {
        txtName.text = user()[index!].name
        txtPhone.text = user()[index!].phone
    }
    
    func delUser() {
        try! realm.write{
            realm.delete(user()[index!])
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        delUser()
        self.dismiss(animated: true)
    }

    @IBAction func onSubmit(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
}
