import UIKit
import RealmSwift

class InviteUserViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var table: UITableView!
    
    let realm = try! Realm()
    var index:Int?
    let color = UIColor(hex: "#4364C9")
    var allCheck: Bool = false
    
    override func viewDidLoad() {
        navigationSetting()
        
        txtName.delegate = self
        self.hideKeyboardWhenTappedAround()
        resetUserMemberDB()
        printPartyName()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textFieldSetting()
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
            titleLabel.text = "파티 관리"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let submitButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(submitButtonTapped))
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        submitButton.setTitleTextAttributes(titleAttributes, for: .normal)
        
        navigationItem.rightBarButtonItem = submitButton
    }
    @objc func submitButtonTapped() {
        delBeforeAlert()
        changePartyName()
    }
    
    func textFieldSetting() {
        txtName.borderStyle = .none
        
        // 기존의 bottomLine을 제거
        txtName.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: txtName.frame.size.height - 1, width: txtName.frame.size.width, height: 1))
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLine.backgroundColor = color
        }
        txtName.addSubview(bottomLine)
    }
    
    func user() -> Results<User> {
        return realm.objects(User.self)
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            user()[userIndex!].member = value
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
    
    func addUser(userIndex: Int) {
        try! realm.write {
            let existingUser = realm.objects(User.self).filter("id == %@", user()[userIndex].id).first
                
                if let existingUser = existingUser {
                    party()[index!].addUser(user: existingUser)
                } else {
                    //party()[index!].addUser(id: user()[userIndex].id, name: user()[userIndex].name)
                }
        }
    }
    
    func checkExistingUser(indexPathRow: Int) -> Bool {
        for i in 0..<party()[index!].user.count {
            if(user()[indexPathRow].id == party()[index!].user[i].id) {
                return true
            }
        }
        return false
    }
    
    func delBeforeAlert() {
        let alert = UIAlertController(title: "파티방 정보 변경", message: "파티방 정보를 변경하시겠습니까?\n(파티원 삭제 시 모든 장소 및 메뉴에서 삭제됩니다.)", preferredStyle: .alert)
        let clear = UIAlertAction(title: "확인", style: .default) { (_) in
            for i in 0..<self.user().count {
                if(self.user()[i].member == 0) {
                    if(self.checkExistingUser(indexPathRow: i)) {
                        self.delUser(userIndex: i)
                        self.sortUser()
                    }
                } else {
                    if(self.checkExistingUser(indexPathRow: i) == false) {
                        self.addUser(userIndex: i)
                        self.sortUser()
                    }
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
    }
    
    func delUser(userIndex: Int) {
        try! realm.write {
            
            if let userIndex = party()[index!].user.index(of: user()[userIndex]) {
                party()[index!].user.remove(at: userIndex)
                for place in user()[userIndex].places {
                    if let userIndexInPlace = place.enjoyer.index(of: user()[userIndex]) {
                        place.enjoyer.remove(at: userIndexInPlace)
                    }
                }
                for menu in user()[userIndex].menus {
                    if let userIndexInMenu = menu.enjoyer.index(of: user()[userIndex]) {
                        menu.enjoyer.remove(at: userIndexInMenu)
                    }
                }
            }
        }
    }
    
    func sortUser() {
        try! realm.write {
            party()[index!].user.sort(by: { $0.id! < $1.id! })
        }

    }
    
    func printPartyName() {
        txtName.text = party()[index!].name
    }
    
    func changePartyName() {
        if (txtName.text != "") {
            try! realm.write {
                party()[index!].name = txtName.text
            }
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "파티 삭제", message: "파티를 삭제하면 모든 정보가 삭제됩니다.", preferredStyle: .alert)
        let clear = UIAlertAction(title: "삭제", style: .destructive) { (_) in
            try! self.realm.write {
                self.realm.delete(self.party()[self.index!])
            }
            if let navigationController = self.navigationController {
                    let viewControllers = navigationController.viewControllers
                    guard viewControllers.count >= 3 else {
                        // 이전 화면이 적어도 3개 이상 있어야 함
                        return
                    }
                    
                    let previousViewController = viewControllers[viewControllers.count - 3]
                    navigationController.popToViewController(previousViewController, animated: true)
                }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
    }
    
}

extension InviteUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = user()[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteUserTableCell") as! InviteUserTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        
        if(checkExistingUser(indexPathRow: indexPath.row) == true) {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
}

extension InviteUserViewController: TableViewCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        if let image = button?.image(for: .normal), image != UIImage(named: "icon_notcheck.png") {
            button?.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
        } else {
            button?.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
        }
    }
    
}

extension InviteUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
