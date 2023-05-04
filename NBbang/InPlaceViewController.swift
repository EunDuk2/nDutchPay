import UIKit

class InPlaceViewController: UIViewController {
    
    var place: Place?
    
    var index:Int?
    
    override func viewDidLoad() {
        navigationItem.title = place?.name
    }
    
}
