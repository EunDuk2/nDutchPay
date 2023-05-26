import UIKit
import RealmSwift

class InPartyViewController: UIViewController {
    let realm = try! Realm()
    var index:Int?
    let color = UIColor(hex: "#4364C9")
    
    @IBOutlet var table: UITableView!
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblUsers: UILabel!
    
    override func viewDidLoad() {
        viewSetting()
        navigationSetting()
        printInitLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.reloadData()
        if let i = index {
            navigationItem.title = party()[i].name
            navigationItem.title! += " ("+String(party()[i].user.count)+")"
        }
    }
    
    func viewSetting() {
        viewLabel.layer.cornerRadius = 10
        viewLabel.clipsToBounds = true
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
            titleLabel.text = party()[index!].name
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        let settleButton = UIButton(type: .custom)
        settleButton.setImage(UIImage(named: "icon_settle.png")?.withRenderingMode(.alwaysOriginal), for: .normal)
        settleButton.setTitle("정산", for: .normal)
        settleButton.titleLabel?.font = UIFont(name: "SeoulNamsanCM", size: 18)
        settleButton.sizeToFit() // 버튼 크기 조정
        settleButton.addTarget(self, action: #selector(settleButtonTapped), for: .touchUpInside)

        let settleBarButtonItem = UIBarButtonItem(customView: settleButton)
        navigationItem.rightBarButtonItem = settleBarButtonItem

    }
    
    @objc func settleButtonTapped() {
        
    }
    
    func printInitLabel() {
        lblPrice.text = fc(amount: party()[index!].totalPrice) + "(원)"
        
        var users: String = ""
        users += "("
        for i in 0..<party()[index!].user.count {
            if(i != party()[index!].user.count - 1) {
                users += party()[index!].user[i].name! + ","
            } else {
                users += party()[index!].user[i].name!
            }
            
        }
        users += ")"
        
        lblUsers.text = users
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func place() -> Results<Place> {
        return realm.objects(Place.self)
    }
    
    func addPlaceNsaveDB(name:String?, price: Int) {
        
        try! realm.write {
            realm.add(Place(name: name, totalPrice: price))
        }
    }
    
    func addPlace(name:String?, totalPrice:Int) {
        try! realm.write {
            party()[self.index!].addPlace(name: name, totalPrice: totalPrice)
        }
    }
    
    @IBAction func onInviteUser(_ sender: Any) {
        
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InviteUserViewController") as? InviteUserViewController else {
                    return
                }
        na.index = index
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    @IBAction func onAddPlace(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as? AddPlaceViewController else {
                    return
                }
        
        //du.index = indexPath.row
        //du.date = checkKey()
        du.party = party()[index!]
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
        
    }
    
}

extension InPartyViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return party()[index!].place.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var row = party()[index!].place[indexPath.section].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableCell") as! PlaceTableCell
        
        cell.lblPlaceName?.text = row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPlaceViewController") as? InPlaceViewController else {
                    return
                }
        //na.index = indexPath.row
        na.place = party()[index!].place[indexPath.section]
        na.party = party()[index!]

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
extension UIViewController {
    // formatCurrency()
    func fc(amount: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "ko_KR")
        
        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            return ""
        }
    }
}
