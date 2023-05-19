import UIKit

class InPlaceViewController: UIViewController {
    
    var party: Party?
    var place: Place?
    var index:Int?
    
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblPlaceEnjoyer: UILabel!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        navigationItem.title = place?.name
        updateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabel()
        table.reloadData()
    }
    
    func updateLabel() {
        lblTotalPrice.text = fc(amount: place!.totalPrice)
        
        var temp: String = ""
        for i in 0..<(place?.enjoyer.count)! {
            if(i != (place?.enjoyer.count)!-1) {
                temp += (place?.enjoyer[i].name)! + ","
            } else {
                temp += (place?.enjoyer[i].name)!
            }
            
        }
        lblPlaceEnjoyer.text = temp
    }
    
    
    
    @IBAction func onAddMenu(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "AddMenuViewController") as? AddMenuViewController else {
                    return
                }
        du.place = self.place
        du.party = self.party
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
    }
    
    @IBAction func onSettle(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "SettleViewController") as? SettleViewController else {
                    return
                }
        du.party = self.party
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
    }
    
    @IBAction func onEdit(_ sender: Any) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "EditPlaceViewController") as? EditPlaceViewController else {
            return
        }
        
        na.party = self.party
        na.place = self.place
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
}

extension InPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Returns the number of sections.
       func numberOfSections(in tableView: UITableView) -> Int {
           return 2
       }
       
   // Returns the title of the section.
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
       let sections:[String] = ["추가되지 않은 메뉴", "추가된 메뉴"]
       
       return sections[section]
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if((place?.menu.count)! > 0) {
                return (place?.menu.count)!
            }
         
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        if indexPath.section == 0 {
                cell.lblName.text = place?.defaultMenu!.name
                
                var calEnjoyer: String? = "("
                for i in 0..<(place?.defaultMenu!.enjoyer.count)! {
                    if(i != (place?.defaultMenu!.enjoyer.count)!) {
                        calEnjoyer! += (place?.defaultMenu!.enjoyer[i].name)! + ", "
                    } else {
                        calEnjoyer! += (place?.defaultMenu!.enjoyer[i].name)!
                    }
                }
                calEnjoyer! += ")"

                cell.lblEnjoyer.text = calEnjoyer
                cell.lblTotalPrice.text = String((place?.defaultMenu?.totalPrice)!)
        }
        else if indexPath.section == 1 {
                let row1 = place?.menu[indexPath.row].name
                var row2: String = "("
                let row3 = place?.menu[indexPath.row].totalPrice
                
                for i in 0..<(place?.menu[indexPath.row].enjoyer.count)! {
                    if(i != (place?.menu[indexPath.row].enjoyer.count)!-1) {
                        row2 += (place?.menu[indexPath.row].enjoyer[i].name)! + ", "
                    } else {
                        row2 += (place?.menu[indexPath.row].enjoyer[i].name)!
                    }
                    
                }
                row2 += ")"
                
                cell.lblName.text = row1
                cell.lblEnjoyer.text = row2
                cell.lblTotalPrice.text = String(row3!) + "(원)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 고정된 높이 값을 반환합니다.
    }
    
}
extension InPlaceViewController {
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

