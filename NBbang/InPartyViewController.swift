import UIKit
import RealmSwift

class InPartyViewController: UIViewController {
    let realm = try! Realm()
    var index:Int?
    let color = UIColor(hex: "#B1B2FF")
    
    @IBOutlet var table: UITableView!
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblUsers: UILabel!
    @IBOutlet var lblAddAlert: UILabel!
    
    override func viewDidLoad() {
        viewSetting()
        navigationSetting()
        printInitLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.reloadData()
        printInitLabel()
        if(party()[index!].place.count != 0 ) {
            lblAddAlert.isHidden = true
        } else {
            lblAddAlert.isHidden = false
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
        
        let settingButtonImage = UIImage(named: "icon_setting3.png")
        let buttonSize = CGSize(width: 30, height: 30)
        UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let resizedImage = UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let settingButton = UIBarButtonItem(title: "", image: resizedImage, target: self, action: #selector(settingButtonTapped))

        let settleButton = UIBarButtonItem(title: "정산", style: .plain, target: self, action: #selector(settleButtonTapped))
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        settleButton.setTitleTextAttributes(titleAttributes, for: .normal)

        navigationItem.rightBarButtonItems = [settingButton, settleButton]
        
        let backBarButtonItem = UIBarButtonItem(title: "장소 목록", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    @objc func settleButtonTapped() {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "SettleViewController") as? SettleViewController else {
                    return
                }
        na.party = party()[index!]
        
        let navigationController = UINavigationController(rootViewController: na)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    @objc func settingButtonTapped() {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InviteUserViewController") as? InviteUserViewController else {
                    return
                }
        na.index = index
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    func printInitLabel() {
        lblPrice.text = fc(amount: party()[index!].totalPrice) + "(원)"
        
        var users: String = String(party()[index!].user.count)
        users += "명("
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
    
    @IBAction func onAddPlace(_ sender: Any) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as? AddPlaceViewController else {
                    return
                }

        na.party = party()[index!]
        
        let navigationController = UINavigationController(rootViewController: na)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
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
        
        var row1 = party()[index!].place[indexPath.section].name
        var row2 = fc(amount: party()[index!].place[indexPath.section].totalPrice) + "(원)"
        var row3 = "("
        for i in 0..<party()[index!].place[indexPath.section].enjoyer.count {
            if(i != party()[index!].place[indexPath.section].enjoyer.count-1) {
                row3 += party()[index!].place[indexPath.section].enjoyer[i].name! + ","
            } else {
                row3 += party()[index!].place[indexPath.section].enjoyer[i].name!
            }
        }
        row3 += ")"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableCell") as! PlaceTableCell
        
        cell.lblPlaceName?.text = row1
        cell.lblPrice?.text = row2
        cell.lblUsers?.text = row3
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPlaceViewController") as? InPlaceViewController else {
                    return
                }
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
