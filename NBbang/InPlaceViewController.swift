import UIKit

class InPlaceViewController: UIViewController {
    
    var place: Place?
    
    var index:Int?
    
    override func viewDidLoad() {
        navigationItem.title = place?.name
    }
    
}

extension InPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        return cell
    }
    
    
}
