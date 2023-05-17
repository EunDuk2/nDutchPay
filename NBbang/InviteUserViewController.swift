import UIKit
import RealmSwift

class InviteUserViewController: UIViewController {
    
    let realm = try! Realm()
    var index:Int?
    
    override func viewDidLoad() {
        resetUserMemberDB()
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
        let alert = UIAlertController(title: "파티원 추가 및 삭제", message: "파티원을 편집하시겠습니까?\n파티원 삭제 시 모든 장소 및 메뉴에서 삭제됩니다.", preferredStyle: .alert)
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
    
    @IBAction func onSubmit(_ sender: Any) {
        delBeforeAlert()
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
