import UIKit
import ContactsUI

class AddUserViewController: UserViewController, CNContactPickerDelegate {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var lblNameWarning: UILabel!
    @IBOutlet var lblPhoneWarning: UILabel!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    
    var maxLength:Int = 8
    var nameBool: Bool = false
    var phoneBool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.isEnabled = false
        
        name.delegate = self
        phone.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(nameDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: name)
        
        NotificationCenter.default.addObserver(self, selector: #selector(phoneDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: phone)
        
    }
    
    func isSubmit() {
        if(nameBool == true && phoneBool == true) {
            btnSubmit.isEnabled = true
        } else {
            btnSubmit.isEnabled = false
        }
    }
    
    func isPhone(candidate: String) -> Bool {

            let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{4})-?([0-9]{4})$"

            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let idText: String = "U" + String(user().count)
        
        addUserNsaveDB(id: idText, name: name.text!, phone: phone.text!, account: account.text!)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onGetContact(_ sender: Any) {
        let contactPickerViewController = CNContactPickerViewController()
                contactPickerViewController.delegate = self
                self.present(contactPickerViewController, animated: true, completion: nil)
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // 선택된 연락처 정보를 처리하는 코드를 작성합니다.
        
        name.text = contact.givenName + contact.familyName
        checkName(text: contact.givenName + contact.familyName, textField: name)
        
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            let formattedPhoneNumber = formatPhoneNumber(phoneNumber)
            phone.text = formattedPhoneNumber
            checkPhone(text: formattedPhoneNumber, textField: phone)
        } else {
            phone.text = "No phone number available"
        }

        
    }
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if digits.hasPrefix("82") {
            let index = digits.index(digits.startIndex, offsetBy: 2)
            let phone = digits[index...]
            return "010\(phone)"
        } else if digits.hasPrefix("0") {
            let index = digits.index(digits.startIndex, offsetBy: 1)
            let phone = digits[index...]
            return "+82\(phone)"
        }
        
        return phoneNumber
    }
}

extension AddUserViewController: UITextFieldDelegate {
    func checkName(text: String, textField: UITextField) {
        
        if text.count >= maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            let newString = text[text.startIndex..<index]
            textField.text = String(newString)
        } else {
            if text.count < 1 {
                lblNameWarning.text = "1글자 이상 8글자 이하로 입력해주세요"
                lblNameWarning.textColor = .red
                nameBool = false
                isSubmit()
            }
            else {
                lblNameWarning.text = "사용 가능한 닉네임입니다."
                lblNameWarning.textColor = .green
                nameBool = true
                isSubmit()
            }
        }
    }
    func checkPhone(text: String, textField: UITextField) {
        if text.count >= 11 {
            let index = text.index(text.startIndex, offsetBy: 11)
            let newString = text[text.startIndex..<index]
            textField.text = String(newString)
        }
        if text.count <= 10 {
            lblPhoneWarning.text = "전화번호를 알맞게 입력해주세요"
            lblPhoneWarning.textColor = .red
            phoneBool = false
            isSubmit()
        }
        else {
            if(isPhone(candidate: textField.text!) == true) {
                phoneBool = true
                lblPhoneWarning.text = "형식에 맞는 전화 번호입니다"
                lblPhoneWarning.textColor = .green
                isSubmit()
            } else {
                lblPhoneWarning.text = "전화번호를 알맞게 입력해주세요"
                lblPhoneWarning.textColor = .red
                phoneBool = false
                isSubmit()
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text else {return false}
            
            // 최대 글자수 이상을 입력한 이후에는 중간에 다른 글자를 추가할 수 없게끔 작동
            if text.count >= maxLength && range.length == 0 && range.location < maxLength {
                return false
            }
            
            return true
        }
    
    @objc private func nameDidChange(_ notification: Notification) {
            if let textField = notification.object as? UITextField {
                if let text = textField.text {
                    checkName(text: text, textField: textField)
                }
            }
        }
    @objc private func phoneDidChange(_ notification: Notification) {
            if let textField = notification.object as? UITextField {
                if let text = textField.text {
                    checkPhone(text: text, textField: textField)
                }
            }
        }
}

