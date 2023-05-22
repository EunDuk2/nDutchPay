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
        var lbl: String = "파티명: "
        lblPartyInfo.text! += (party?.name)! + "/" + String((party?.user.count)!) + "명\n총 사용 금액: "
        lblPartyInfo.text! += String((party?.totalPrice)!)
    }
    
    func calPlaceUserMoney(place: Place) -> String {
        var money =  place.totalPrice / place.enjoyer.count
        
        return String(money)
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
            
            var row1 = (party?.place[indexPath.row].name)! + "(" + String((party?.place[indexPath.row].enjoyer.count)!) +  "), "
            var row2 = String((party?.place[indexPath.row].totalPrice)!) + "(원)"
            var row3:String = ""
            
            for i in 0..<(party?.place[indexPath.row].enjoyer.count)! {
                row3 += (party?.place[indexPath.row].enjoyer[i].name)!
                row3 += "("
                row3 += calPlaceUserMoney(place: (party?.place[indexPath.row])!)
                row3 += "원)"
            }
            
            cell.lblName.text = row1 + row2
            cell.lblUsers.text = row3
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 1) {
            return 70
        } else {
            return 44
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
