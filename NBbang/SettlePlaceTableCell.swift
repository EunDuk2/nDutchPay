import UIKit

class SettlePlaceTableCell: UITableViewCell {
    //let realm = try! Realm()
    var party: Party?
    var place: Place?
    var index: Int?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblUsers: UILabel!
    @IBOutlet var menuTable: UITableView!
    
    var isExpanded = false
    let originalHeight: CGFloat = 70.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        menuTable.delegate = self
        menuTable.dataSource = self
        
        //menuTable.frame.size.height = CGFloat(44 * (party?.place[index!].menu.count)!)
       
    }
    
}

extension SettlePlaceTableCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuTable.frame.size.height = CGFloat(44 * (party?.place[index!].menu.count)!)
        return (party?.place[index!].menu.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettleMenuTableCell") as! SettleMenuTableCell
        
        cell.lblMenuInfo.text = party?.place[index!].menu[indexPath.row].name
        
        return cell
    }
}

