import UIKit
import RealmSwift

class AddPartyViewController: UIViewController {
    
    @IBOutlet var partyName: UITextField!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        resetUserMemberDB()
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
    
    @IBAction func onAddParty(_ sender: Any) {
        if(partyName.text == "") {
            addPartyNsaveDB(name: "이름 없는 파티방"+String(party().count+1))
        }
        for i in 0..<user().count {
            if(user()[i].member == 1) {
                addUser(userIndex: i)
            }
        }
        self.navigationController?.popViewController(animated: true)
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
        cell.btnCheck.setTitle("🟩", for: .normal)
        
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
