import RealmSwift
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var btnAdd: UIButton!
    
    let color = UIColor(hex: "#B1B2FF")
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        
        firstLaunch()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
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
            titleLabel.text = "파티 목록"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        let addButtonImage = UIImage(named: "icon_menu.png")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIBarButtonItem(title: "", image: addButtonImage, target: self, action: #selector(addButtonTapped))

        navigationItem.rightBarButtonItem = addButton
        
        let backBarButtonItem = UIBarButtonItem(title: "파티목록", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    @objc func addButtonTapped() {
        eraseDB()
    }

    func firstLaunch() {
        if UserDefaults.standard.bool(forKey: "launchedBefore") == false {
            
            guard let na = self.storyboard?.instantiateViewController(withIdentifier: "AddUserViewController") as? AddUserViewController else {
                return
            }
            na.initBool = true
            
            let navigationController = UINavigationController(rootViewController: na)
            
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func eraseDB() {
        // 아예 Realm 파일 삭제
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                // handle error
            }
        }
    }
    
    func addPartyNsaveDB(name: String?) {
        try! realm.write {
            realm.add(Party(name: name))
        }
    }
    
    func deleteDB(i: Int) {
        try! realm.write {
            realm.delete(party()[i])
        }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func cnt() -> Int {
        return party().count
    }

    @IBAction func addParty(_ sender: Any) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "AddPartyViewController") as? AddPartyViewController else {
            return
        }

        let navigationController = UINavigationController(rootViewController: na)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func onDeleteDB(_ sender: Any) {
        eraseDB()
        table.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cnt()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = party()[indexPath.section].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyTableCell") as! PartyTableCell
        
        cell.partyName?.text = row
        cell.userList?.text = userList(index: indexPath.section)
        
        
        
        return cell
    }
    
    func userList(index: Int) -> String {
        var userList: String = ""
        userList += String(party()[index].user.count) + "명 ("
        for i in 0..<party()[index].user.count {
            if i < party()[index].user.count-1 {
                userList += party()[index].user[i].name! + ","
            } else {
                userList += party()[index].user[i].name!
            }
        }
        userList += ")"
        return userList
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPartyViewController") as? InPartyViewController else {
            return
        }
        na.index = indexPath.section
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0.1
        }
        return -1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 섹션 푸터의 높이를 조정하는 로직을 구현
        return 10
    }
    
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
