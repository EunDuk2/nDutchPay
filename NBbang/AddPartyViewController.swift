import UIKit
import RealmSwift

class AddPartyViewController: UIViewController {
    
    @IBOutlet var partyName: UITextField!
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var table: UITableView!
    @IBOutlet var textField: UITextField!
    
    let realm = try! Realm()
    var allCheck: Bool = false
    let color = UIColor(hex: "#4364C9")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetting()
        textFieldSetting()
        resetUserMemberDB()
        self.hideKeyboardWhenTappedAround()
        partyName.delegate = self
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
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        addButton.setTitleTextAttributes(titleAttributes, for: .normal)
        
        navigationItem.rightBarButtonItem = addButton
    }
    @objc func addButtonTapped() {
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
    
    func textFieldSetting() {
        textField.borderStyle = .none
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLine.backgroundColor = color.cgColor
        }
        textField.layer.addSublayer(bottomLine)

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
    
    @IBAction func onAllCheck(_ sender: Any) {
        if(allCheck == false) {
            allCheck = true
            btnCheck.setTitle("✅ 전체 해제", for: .normal)
            setUserMemberDB()
        } else {
            allCheck = false
            btnCheck.setTitle("🟩 전체 선택", for: .normal)
            resetUserMemberDB()
        }
        table.reloadData()
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
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
            cell.btnCheck.setTitle("🟩", for: .normal)
        } else {
            cell.btnCheck.setTitle("✅", for: .normal)
        }
        
        
        
        cell.delegate = self
        
        return cell
    }
    
}

extension AddPartyViewController: TableViewCellDelegate {
    
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        
        if(button?.title(for: .normal) != "🟩") {
            button?.setTitle("🟩", for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
        } else {
            button?.setTitle("✅", for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
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
