import UIKit

class PartyTableCell: UITableViewCell {
    
    @IBOutlet var partyName: UILabel!
    @IBOutlet var userList: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // 셀의 모서리를 둥글게 설정
            self.layer.cornerRadius = 15
            self.clipsToBounds = true
        }
}
