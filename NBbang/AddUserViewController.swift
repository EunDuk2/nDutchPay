import UIKit
import ContactsUI

class AddUserViewController: UserViewController, CNContactPickerDelegate {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var lblNameWarning: UILabel!
    @IBOutlet var lblPhoneWarning: UILabel!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var btnCancel: UIBarButtonItem!
    
    @IBOutlet var nameLeading: NSLayoutConstraint!
    @IBOutlet var nameTrailling: NSLayoutConstraint!
    
    var maxLength:Int = 8
    var nameBool: Bool = false
    var phoneBool: Bool = false
    var initBool: Bool = false
    
    func constraintSetting() {
        view.removeConstraint(nameLeading)
        view.removeConstraint(nameTrailling)

        // 새로운 multiplier 값을 가진 제약 조건을 생성합니다
        let newLeadingConstraint = NSLayoutConstraint(item: name, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 16)
        let newTrailingConstraint = NSLayoutConstraint(item: name, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -16)

        // 새로운 제약 조건을 추가합니다
        view.addConstraint(newLeadingConstraint)
        view.addConstraint(newTrailingConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintSetting()
        
        navigationSetting()
        textFieldSetting()
        self.hideKeyboardWhenTappedAround()
        
        if(initBool == true) {
            if let titleView = navigationItem.titleView as? UILabel {
                titleView.textColor = .white
                titleView.font = UIFont(name: "SeoulNamsanCM", size: 21)
            } else {
                let titleLabel = UILabel()
                titleLabel.text = "본인 등록"
                titleLabel.textColor = .white
                titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
                navigationItem.titleView = titleLabel
            }
            btnCancel?.isHidden = true
        }
        
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
    
    @objc override func navigationSetting() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = color
        navigationController!.navigationBar.standardAppearance = navigationBarAppearance
        navigationController!.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        if let titleView = navigationItem.titleView as? UILabel {
            titleView.textColor = .white
            titleView.font = UIFont(name: "SeoulNamsanCM", size: 21)
        } else {
            let titleLabel = UILabel()
            titleLabel.text = "친구 등록"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let submitButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(submitButtonTapped))
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let contactButtonImage = UIImage(named: "icon_cantac2.png")?.withRenderingMode(.alwaysOriginal)
        let contactButton = UIBarButtonItem(image: contactButtonImage, style: .plain, target: self, action: #selector(contactButtonTapped))
        
        btnSubmit = submitButton

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        submitButton.setTitleTextAttributes(titleAttributes, for: .normal)
        cancelButton.setTitleTextAttributes(titleAttributes, for: .normal)

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItems = [submitButton, contactButton]

    }
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    @objc func submitButtonTapped() {
        let idText: String = "U" + String(user().count)
        
        addUserNsaveDB(id: idText, name: name.text!, phone: phone.text!, account: nil)
        
        self.dismiss(animated: true)
    }
    @objc func contactButtonTapped() {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        self.present(contactPickerViewController, animated: true, completion: nil)
    }
    
    func textFieldSetting() {
        name.borderStyle = .none
        phone.borderStyle = .none
        
        let bottomLine1 = CALayer()
        let bottomLine2 = CALayer()
        bottomLine1.frame = CGRect(x: 0, y: name.frame.height - 1, width: phone.frame.width, height: 1)
        bottomLine2.frame = CGRect(x: 0, y: name.frame.height - 1, width: phone.frame.width, height: 1)
        
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLine1.backgroundColor = color.cgColor
            bottomLine2.backgroundColor = color.cgColor
        }
        name.layer.addSublayer(bottomLine1)
        phone.layer.addSublayer(bottomLine2)
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
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // 선택된 연락처 정보를 처리하는 코드를 작성합니다.
        
        name.text = contact.givenName + contact.familyName
        checkName(text: contact.givenName + contact.familyName, textField: name)
        
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            let digitsOnly = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            var formattedPhoneNumber: String
            if digitsOnly.hasPrefix("82") {
                formattedPhoneNumber = "010" + digitsOnly.dropFirst(2)
            } else {
                formattedPhoneNumber = digitsOnly
            }
            phone.text = formattedPhoneNumber
            checkPhone(text: formattedPhoneNumber, textField: phone)
        } else {
            phone.text = "No phone number available"
        }

    }
}

extension AddUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func checkName(text: String, textField: UITextField) {
        
        if text.count >= maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            let newString = text[text.startIndex..<index]
            textField.text = String(newString)
        } else {
            if text.count < 1 {
                lblNameWarning.text = "1글자 이상 8글자 이하로 입력해주세요"
                lblNameWarning.textColor = UIColor(hex: "#C24446")
                nameBool = false
                isSubmit()
            }
            else {
                lblNameWarning.text = "사용 가능한 닉네임입니다"
                lblNameWarning.textColor = UIColor(hex: "#54C275")
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
            lblPhoneWarning.textColor = UIColor(hex: "#C24446")
            phoneBool = false
            isSubmit()
        }
        else {
            if(isPhone(candidate: textField.text!) == true) {
                phoneBool = true
                lblPhoneWarning.text = "형식에 맞는 전화 번호입니다"
                lblPhoneWarning.textColor = UIColor(hex: "#54C275")
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
