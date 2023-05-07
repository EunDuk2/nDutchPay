import UIKit
import RealmSwift

class AddMenuViewController: UIViewController {
    
    
    
    @IBAction func onSubmit(_ sender: Any) {
        
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension AddMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMenuTableCell") as! AddMenuTableCell
        
        return cell
    }
    
}
