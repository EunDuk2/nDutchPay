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
    
    @IBAction func onSubmit(_ sender: Any) {
        
        for i in 0..<user().count {
            if(user()[i].member == 1) {
                addUser(userIndex: i)
            }
            
        }
        
        self.navigationController?.popViewController(animated: true)
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
            cell.btnCheck?.isEnabled = false
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
