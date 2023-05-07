import UIKit

protocol MenuAddCellDelegate: AnyObject {
    func didTapButton(cellIndex: Int?, button: UIButton?)
}

class AddMenuTableCell: UITableViewCell {
    var index: Int?
    
    weak var delegate: MenuAddCellDelegate?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnCheck: UIButton!
    
    @IBAction func onCheck(_ sender: Any) {
        self.delegate?.didTapButton(cellIndex: index, button: btnCheck)
    }
}
