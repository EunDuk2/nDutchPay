import UIKit
import RealmSwift

class UserViewController: UIViewController {
    
    let realm = try! Realm()
    let color = UIColor(hex: "#B1B2FF")
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tableView = table {
                tableView.reloadData()
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
            titleLabel.text = "친구 목록"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            try! realm.write {
                realm.delete(user()[indexPath.row])
            }
            table.deleteRows(at: [indexPath], with: .fade)
            table.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }

}
