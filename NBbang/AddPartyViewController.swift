import UIKit
import RealmSwift

class AddPartyViewController: UIViewController {
    
    @IBOutlet var partyName: UITextField!
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var table: UITableView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var lblAddAlert: UILabel!
    
    let realm = try! Realm()
    var allCheck: Bool = false
    let color = UIColor(hex: "#B1B2FF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetting()
        resetUserMemberDB()
        self.hideKeyboardWhenTappedAround()
        partyName.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textFieldSetting()
        
        if(user().count == 1) {
            lblAddAlert.isHidden = false
        } else {
            lblAddAlert.isHidden = true
        }
    }

    
    @objc func navigationSetting() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = color
        navigationController!.navigationBar.standardAppearance = navigationBarAppearance
        navigationController!.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        if let titleView = navigationItem.titleView as? UILabel {
            titleView.textColor = .white
            titleView.font = UIFont(name: "SeoulNamsanCM", size: 21)
        } else {
            let titleLabel = UILabel()
            titleLabel.text = "파티 생성"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let addButton = UIBarButtonItem(title: "만들기", style: .plain, target: self, action: #selector(addButtonTapped))
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        addButton.setTitleTextAttributes(titleAttributes, for: .normal)
        cancelButton.setTitleTextAttributes(titleAttributes, for: .normal)
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    @objc func addButtonTapped() {
        if(checkZeroUser(user: user())) {
            if(partyName.text == "") {
                addPartyNsaveDB(name: "이름 없는 파티방"+String(partyNameCount()))
            } else {
                addPartyNsaveDB(name: partyName.text!)
            }
            for i in 0..<user().count {
                if(user()[i].member == 1) {
                    addUser(userIndex: i)
                }
            }
            self.dismiss(animated: true)
        }
    }
    
    func textFieldSetting() {
        textField.borderStyle = .none
        
        // 기존의 bottomLine을 제거
        textField.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: textField.frame.size.height - 1, width: textField.frame.size.width, height: 1))
        let hexColor = "#B1B2FF"
        if let color = UIColor(hex: hexColor) {
            bottomLine.backgroundColor = color
        }
        textField.addSubview(bottomLine)
    }
    
    func checkZeroUser(user:Results<User>) -> Bool {
        for i in 0..<user.count {
            if(user[i].member == 1) {
                return true
            }
        }
        let alert = UIAlertController(title: "알림", message: "최소 한명 이상의 파티원을 선택해주세요.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true)
        return false
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func user() -> Results<User> {
        return realm.objects(User.self)
    }
    
    func addPartyNsaveDB(name:String?) {
        
        try! realm.write {
            realm.add(Party(name: name))
        }
    }
    
    func resetUserMemberDB() {
        for i in 0..<user().count {
            try! realm.write {
                user()[i].member = 0
            }
        }
    }
    func setUserMemberDB() {
        for i in 0..<user().count {
            try! realm.write {
                user()[i].member = 1
            }
        }
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            user()[userIndex!].member = value
        }
    }
    
    func addUser(userIndex: Int) {
        try! realm.write {
            let existingUser = realm.objects(User.self).filter("id == %@", user()[userIndex].id).first
                
                if let existingUser = existingUser {
                    party()[party().count-1].addUser(user: existingUser)
                } else {
                    //party()[index!].addUser(id: user()[userIndex].id, name: user()[userIndex].name)
                }
        }
    }
    
    func partyNameCount() -> Int {
        do {
            let partiesWithName = realm.objects(Party.self).filter("name CONTAINS %@", "이름 없는 파티방")
            let count = partiesWithName.count
            return count + 1
        } catch {
            print("Realm 오류: \(error)")
            return 0
        }
    }
    
    func checkAllButtonBool() {
        var tempBool: Bool = true
        
        for i in 0..<user().count {
            if(user()[i].member == 0) {
                tempBool = false
            }
        }
        setBtnCheck(bool: tempBool)
    }
    
    func setBtnCheck(bool: Bool) {
        let image: UIImage?
        let title: String?
        let font = UIFont(name: "SeoulNamsanCM", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let textColor = color
        
        if(bool == true) {
            image = UIImage(named: "icon_check1.png")
            title = "전체 해제"
            
        } else {
            image = UIImage(named: "icon_notcheck1.png")
            title = "전체 선택"
        }

        btnCheck.setImage(image, for: .normal)
        btnCheck.setTitle(title, for: .normal)
        btnCheck.titleLabel?.font = font
        btnCheck.setTitleColor(textColor, for: .normal)
    }
    
    @IBAction func onAllCheck(_ sender: Any) {
        if(allCheck == false) {
            allCheck = true
            setUserMemberDB()
            setBtnCheck(bool: allCheck)
        } else {
            allCheck = false
            resetUserMemberDB()
            setBtnCheck(bool: allCheck)
        }
        table.reloadData()
    }
    @IBAction func onSubmit(_ sender: Any) {
        if(checkZeroUser(user: user())) {
            if(partyName.text == "") {
                addPartyNsaveDB(name: "이름 없는 파티방"+String(partyNameCount()))
            } else {
                addPartyNsaveDB(name: partyName.text!)
            }
            for i in 0..<user().count {
                if(user()[i].member == 1) {
                    addUser(userIndex: i)
                }
            }
            self.dismiss(animated: true)
        }
        
    }
    @IBAction func onAddUser(_ sender: Any) {
        guard let tabBarController = self.tabBarController else {
                return
            }
            
            tabBarController.selectedIndex = 1 // 탭바 컨트롤러의 1번째 인덱스 아이템으로 이동
            
            // 현재 모달로 표시된 뷰 컨트롤러를 해제
            self.dismiss(animated: true, completion: nil)

    }
    
}

extension AddPartyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = user()[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteUserTableCell") as! InviteUserTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        
        if(allCheck == false) {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
}

extension AddPartyViewController: TableViewCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        if let image = button?.image(for: .normal), image != UIImage(named: "icon_notcheck.png") {
            button?.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
            checkAllButtonBool()
        } else {
            button?.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
            checkAllButtonBool()
        }
    }
    
}

extension AddPartyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
