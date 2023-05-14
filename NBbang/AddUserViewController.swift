import UIKit

class AddUserViewController: UserViewController {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var lblWarning: UILabel!
    
    var maxLength:Int = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: name)
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
    
    @objc private func textDidChange(_ notification: Notification) {
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
                        
                    }
                    else {
                        lblWarning.text = "사용 가능한 닉네임입니다."
                        lblWarning.textColor = .green

                    }
                }
            }
        }
}
