import UIKit
import RealmSwift

class SettleViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    var place: Place?
    var selectedIndexPath: IndexPath? // 선택한 셀의 인덱스를 저장하는 변수
    
    @IBOutlet var lblPartyInfo: UILabel!
    @IBOutlet var table: UITableView!
    
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
    
    func resetPlaceMoney(place: Place) {
        try! realm.write {
            for i in 0..<place.enjoyer.count {
                place.enjoyer[i].placeMoney = 0
            }
        }
    }
    
    func calPlaceUserMoney(place: Place, i:Int) -> String{
        //resetPlaceMoney(place: place)
        var userMoney:Int = 0
        
        try! realm.write {
            userMoney = 0
            
            if(place.defaultMenu?.totalPrice != 0 ) {
                var defaultMoney = place.defaultMenu!.totalPrice / (place.defaultMenu?.enjoyer.count)!
                userMoney += defaultMoney
                
                for i in 0..<place.enjoyer.count {
                    place.enjoyer[i].placeMoney = userMoney
                    print(place.enjoyer[i].name! + String(userMoney))
                }
            }
            
            
            for i in 0..<place.menu.count {
                var tempMoney = place.menu[i].totalPrice / place.menu[i].enjoyer.count
                userMoney += tempMoney
                for j in 0..<place.menu[i].enjoyer.count {
                    place.menu[i].enjoyer[j].placeMoney = userMoney
                    print(place.menu[i].enjoyer[j].name! + String(userMoney))
                }
            }
        }
        
        return fc(amount: place.enjoyer[i].placeMoney)
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
            
            let row1 = party?.user[indexPath.row].name
            let row2 = party?.user[indexPath.row].money
            
            cell.lblName.text = row1
            cell.lblPrice.text = fc(amount: row2!) + " (원)"
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettlePlaceTableCell") as! SettlePlaceTableCell
            
            let row1 = (party?.place[indexPath.row].name)! + "(" + String((party?.place[indexPath.row].enjoyer.count)!) +  "), "
            let row2 = String((party?.place[indexPath.row].totalPrice)!) + "(원)"
            var row3:String = ""
            
            for i in 0..<(party?.place[indexPath.row].enjoyer.count)! {
                row3 += (party?.place[indexPath.row].enjoyer[i].name)!
                row3 += "("
                row3 += calPlaceUserMoney(place: (party?.place[indexPath.row])!, i: i)
                row3 += "원)"
            }
            
            cell.index = indexPath.row
            cell.place = self.place
            cell.party = self.party
            cell.lblName.text = row1 + row2
            cell.lblUsers.text = row3
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 1) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil // 선택한 셀이 이미 있는 경우 해제
            } else {
                selectedIndexPath = indexPath // 선택한 셀의 인덱스 저장
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
            
    }
        
        // 테이블 뷰의 셀 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == 1 {
                if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettlePlaceTableCell") as! SettlePlaceTableCell
                    let menuCount = party?.place[indexPath.row].menu.count ?? 0
                    let menuHeight = CGFloat(44 * menuCount)
                    return 70 + menuHeight
                }
                return 70
            }
            return 44
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
