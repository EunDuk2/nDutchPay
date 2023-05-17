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
    func countBookmarkedUsers() -> Int {
        let bookmarkedUsersCount = realm.objects(User.self).filter("bookmark == true").count
        return bookmarkedUsersCount
    }

}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    // Returns the title of the section.
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        let sections:[String] = ["즐겨찾기", "test"]
//
//        return sections[section]
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return countBookmarkedUsers()
//        } else if section == 1 {
//            return user().count - countBookmarkedUsers()
//        }
//        return 0
//    }
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
