import UIKit

class AddUserViewController: UserViewController {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var account: UITextField!
    
    @IBAction func onSubmit(_ sender: Any) {
        let idText: String = "U" + String(user().count)
        
        addUserNsaveDB(id: idText, name: name.text!, phone: phone.text!, account: account.text!)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
