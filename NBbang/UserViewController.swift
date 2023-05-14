import UIKit
import RealmSwift

class UserViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tableView = table {
                tableView.reloadData()
            }
    }
    
    func user() -> Results<User> {
        return realm.objects(User.self)
    }
    func addUserNsaveDB(id: String?, name: String?, phone: String?, account: String?) {
        try! realm.write {
            realm.add(User(id: id, name: name, phone: phone, account: account))
        }
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = user()[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! UserTableCell
        
        cell.lblUserName?.text = row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "EditUserViewController") as? EditUserViewController else {
                    return
                }
        na.index = indexPath.row

        
        self.navigationController?.pushViewController(na, animated: true)
        
    }
    
}
