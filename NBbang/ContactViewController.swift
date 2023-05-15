import UIKit
import ContactsUI

class ContactViewController: UIViewController, CNContactPickerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        self.present(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // 선택된 연락처 정보를 처리하는 코드를 작성합니다.
        print("Selected contact: \(contact.givenName) \(contact.familyName) \(contact.phoneNumbers)")
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // 연락처 선택을 취소한 경우 처리할 코드를 작성합니다.
        print("Contact picker cancelled.")
    }
}
