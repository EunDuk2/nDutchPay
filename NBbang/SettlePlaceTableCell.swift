import UIKit

// 프로토콜 선언
protocol SettlePlaceTableCellDelegate: AnyObject {
    func didTapButton(cellIndex: Int?, button: UIButton?)
}

class SettlePlaceTableCell: UITableViewCell {
    //let realm = try! Realm()
    var party: Party?
    var place: Place?
    var index: Int?
    weak var delegate: SettlePlaceTableCellDelegate?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblUsers: UILabel!
    @IBOutlet var menuTable: UITableView!
    @IBOutlet var btnCamera: UIButton!
    
    var isExpanded = false
    let originalHeight: CGFloat = 70.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        menuTable.delegate = self
        menuTable.dataSource = self
    }
    
    func calMenuUserMoney(menu: Menu, i: Int) -> String{
        let money = menu.totalPrice / menu.enjoyer.count
        return fc(amount: money)
    }
    
    @IBAction func onCamera(_ sender: Any) {
        self.delegate?.didTapButton(cellIndex: index, button: btnCamera)
    }
    
}

extension SettlePlaceTableCell: UITableViewDelegate, UITableViewDataSource {
    
   func numberOfSections(in tableView: UITableView) -> Int {
       return 2
   }
       
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
       let sections:[String] = ["기본 메뉴", "추가된 메뉴"]
       
       return sections[section]
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        } else {
            
            return (party?.place[index!].menu.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettleMenuTableCell") as! SettleMenuTableCell
        
        if(indexPath.section == 0) {
            var row1: String = ""
            var row2: String = ""
            
            row1 += "기타"
            row1 += "(" + String((party?.place[index!].defaultMenu!.enjoyer.count)!) + "명), "
            row1 += fc(amount: (party?.place[index!].defaultMenu?.totalPrice)!) + "(원)"
            cell.lblMenuInfo.text = row1
            
            for i in 0..<(party?.place[index!].defaultMenu!.enjoyer.count)! {
                row2 += (party?.place[index!].defaultMenu!.enjoyer[i].name)!
                row2 += "("
                row2 += calMenuUserMoney(menu: (party?.place[index!].defaultMenu)!, i: i)
                row2 += "원)"
            }
            cell.lblUsers.text = row2
        } else {
            var row1: String = ""
            var row2: String = ""
            
            row1 += (party?.place[index!].menu[indexPath.row].name)!
            row1 += "(" + String((party?.place[index!].menu[indexPath.row].enjoyer.count)!) + "명), "
            row1 += fc(amount: (party?.place[index!].menu[indexPath.row].totalPrice)!) + "(원)"
            cell.lblMenuInfo.text = row1
            
            for i in 0..<(party?.place[index!].menu[indexPath.row].enjoyer.count)! {
                row2 += (party?.place[index!].menu[indexPath.row].enjoyer[i].name)!
                row2 += "("
                row2 += calMenuUserMoney(menu: (party?.place[index!].menu[indexPath.row])!, i: i)
                row2 += "원)"
            }
            cell.lblUsers.text = row2
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}

extension SettlePlaceTableCell {
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
