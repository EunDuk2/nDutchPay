import UIKit

class AddUserViewController: UserViewController {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var lblWarning: UILabel!
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
}

extension AddUserViewController: UITextFieldDelegate {
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
                    
                    // 초과되는 텍스트 제거
                    if text.count >= maxLength {
                        let index = text.index(text.startIndex, offsetBy: maxLength)
                        let newString = text[text.startIndex..<index]
                        textField.text = String(newString)
                    }
                    
                    else if text.count < 1 {
                        lblWarning.text = "1글자 이상 8글자 이하로 입력해주세요"
                        lblWarning.textColor = .red
                        nameBool = false
                        isSubmit()
                    }
                    else {
                        lblWarning.text = "사용 가능한 닉네임입니다."
                        lblWarning.textColor = .green
                        nameBool = true
                        isSubmit()
                    }
                }
            }
        }
    @objc private func phoneDidChange(_ notification: Notification) {
            if let textField = notification.object as? UITextField {
                if let text = textField.text {
                    
                    // 초과되는 텍스트 제거
                    if text.count >= 11 {
                        let index = text.index(text.startIndex, offsetBy: 11)
                        let newString = text[text.startIndex..<index]
                        textField.text = String(newString)
                    }
                    
                    else {
                        if(isPhone(candidate: textField.text!) == true) {
                            phoneBool = true
                            isSubmit()
                        } else {
                            phoneBool = false
                            isSubmit()
                        }
                    }
                }
            }
        }
}
