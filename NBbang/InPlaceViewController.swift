import UIKit

class InPlaceViewController: UIViewController {
    
    var place: Place?
    
    var index:Int?
    
    override func viewDidLoad() {
        navigationItem.title = place?.name
    }
    
    
    @IBAction func onAddMenu(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "AddMenuViewController") as? AddMenuViewController else {
                    return
                }
        du.place = self.place
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
    }
    
    
}

extension InPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (place?.menu.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = place?.menu[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        cell.lblName.text = row
        
        return cell
    }
    
    
}
