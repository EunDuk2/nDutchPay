import UIKit

protocol AddPlaceUserTableCellDelegate: AnyObject {
    func didTapButton(cellIndex: Int?, button: UIButton?)
}

class AddPlaceUserTableCell: UITableViewCell {
    var index:Int?
    
    weak var delegate: AddPlaceUserTableCellDelegate?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnCheck: UIButton!
    

    @IBAction func onCheck(_ sender: Any) {
        self.delegate?.didTapButton(cellIndex: index, button: btnCheck)
    }
    
}
