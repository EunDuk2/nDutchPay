import UIKit
import RealmSwift

class SettleViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    var place: Place?
    
    @IBOutlet var lblPartyInfo: UILabel!
    
    override func viewDidLoad() {
        printPartyInfoLable()
        plusUserMoney()
    }
    
    func initMoney() {
        for i in 0..<(party?.user.count)! {
            try! realm.write {
                party?.user[i].money = 0
            }
        }
    }
    
    func plusUserMoney() {
        var menu: Menu?
        var count: Int
        
        initMoney()
        
        for i in 0..<(party?.place.count)! {
            // 장소 가져오고
            place = party?.place[i]
            
            let dMenuEnjoyerCount: Int = (place?.defaultMenu?.enjoyer.count)!
            for j in 0..<(dMenuEnjoyerCount) {
                try! realm.write {
                    place?.defaultMenu?.enjoyer[j].money += (place?.defaultMenu!.totalPrice)! / dMenuEnjoyerCount
                }
            }
            
            for j in 0..<(place?.menu.count)! {
                // 장소안에 메뉴랑 사용자 가져오고
                menu = place?.menu[j]
                count = menu!.count
                
                for k in 0..<(menu?.enjoyer.count)! {
                    try! realm.write {
                        menu?.enjoyer[k].money += (menu?.totalPrice)! / (menu?.enjoyer.count)!
                    }
                }
                
            }
        }
    }
    
    func printPartyInfoLable() {
//        try! realm.write {
//            party?.totalPrice = 0
//            for i in 0..<(party?.place.count)! {
//                    party?.totalPrice += (party?.place[i].totalPrice)!
//            }
//        }
        
        var lbl: String = "파티명: "
        lblPartyInfo.text! += (party?.name)! + ", 총 사용 금액: "
        lblPartyInfo.text! += String((party?.totalPrice)!)
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SettleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sections:[String] = ["파티원 정산", "장소 및 메뉴 세부사항"]
        
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0 ) {
            return (party?.user.count)!
        } else {
            return (party?.place.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettleUserTableCell") as! SettleUserTableCell
            
            var row1 = party?.user[indexPath.row].name
            var row2 = party?.user[indexPath.row].money
            
            cell.lblName.text = row1
            cell.lblPrice.text = fc(amount: row2!) + " (원)"
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettlePlaceTableCell") as! SettlePlaceTableCell
            
            var row1 = (party?.place[indexPath.row].name)! + ", "
            var row2 = String((party?.place[indexPath.row].totalPrice)!)
            
            
            
            return cell
        }
    }
    
    
}

extension SettleViewController {
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
