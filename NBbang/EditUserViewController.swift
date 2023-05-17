import UIKit
import RealmSwift

class EditUserViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var lblNameWarning: UILabel!
    @IBOutlet var lblPhoneWarning: UILabel!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var btnBookmark: UIButton!
    
    var maxLength:Int = 8
    var index: Int?
    var nameBool: Bool = true
    var phoneBool: Bool = true
    let realm = try! Realm()
    
    override func viewDidLoad() {
        txtName.delegate = self
        txtPhone.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(nameDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtName)
        
        NotificationCenter.default.addObserver(self, selector: #selector(phoneDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPhone)
        
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
    
    func delCheck() {
        let alert = UIAlertController(title: "친구 삭제", message: user()[index!].name! + " 님을 삭제 하시겠습니까?\n", preferredStyle: .alert)

        let clear = UIAlertAction(title: "확인", style: .default) { (_) in
            self.delUser()
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
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
    
    func updateUserDB(name:String, phone:String) {
        try! realm.write {
            user()[index!].name = name
            user()[index!].phone = phone
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        delCheck()
    }

    @IBAction func onSubmit(_ sender: Any) {
        
        updateUserDB(name: txtName.text!, phone: txtPhone.text!)
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onBookmark(_ sender: Any) {
        if(btnBookmark.title(for: .normal) == "☆") {
            btnBookmark.setTitle("★", for: .normal)
            try! realm.write {
                user()[index!].bookmark = true
            }
        } else {
            btnBookmark.setTitle("☆", for: .normal)
            try! realm.write {
                user()[index!].bookmark = false
            }
        }
    }
    
}

extension EditUserViewController: UITextFieldDelegate {
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
