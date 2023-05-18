import UIKit
import RealmSwift

class InviteUserViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!
    
    let realm = try! Realm()
    var index:Int?
    
    override func viewDidLoad() {
        resetUserMemberDB()
        printPartyName()
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
    
    @IBAction func onSubmit(_ sender: Any) {
        delBeforeAlert()
        changePartyName()
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
            cell.btnCheck?.setTitle("✅", for: .normal)
            
            try! realm.write {
                user()[indexPath.row].member = 1
            }
        } else {
            cell.btnCheck?.setTitle("🟩", for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
}

extension InviteUserViewController: TableViewCellDelegate {
    
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
