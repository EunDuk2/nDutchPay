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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        cell.lblName.text = row1
        cell.lblEnjoyer.text = row2
        cell.lblTotalPrice.text = String(row3!) + "(원)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 고정된 높이 값을 반환합니다.
    }
    
}
