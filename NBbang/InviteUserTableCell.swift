import UIKit

protocol TableViewCellDelegate: AnyObject {
    func didTapButton(cellIndex: Int?, button: UIButton?)
}

class InviteUserTableCell: UITableViewCell {
    var index: Int?
    
    weak var delegate: TableViewCellDelegate?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnCheck: UIButton!
    
    @IBAction func onCheck(_ sender: Any) {
        self.delegate?.didTapButton(cellIndex: index, button: btnCheck)
    }
}
