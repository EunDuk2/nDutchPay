import UIKit
import RealmSwift

class AddMenuViewController: UIViewController, MenuAddCellDelegate {
    let realm = try! Realm()
    var place: Place?
    var party: Party?
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtCount: UITextField!
    
    
    
    override func viewDidLoad() {
        resetUserMemberDB()
    }
    override func viewWillAppear(_ animated: Bool) {
        resetUserMemberDB()
    }
    
    func resetUserMemberDB() {
        for i in 0..<(place?.enjoyer.count)! {
            try! realm.write {
                place?.enjoyer[i].member = 1
            }
        }
    }
    
    func addMenuUser(user:User?) {
        try! realm.write {
            place?.menu[(place?.menu.count)!-1].addEnjoyer(user: user!)
        }
        
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        try! realm.write {
            place?.addMenu(name: txtName.text ,price: Int(txtPrice.text ?? "") ?? 0, count: Int(txtCount.text ?? "") ?? 0)
            place?.plusPrice(price: (Int(txtPrice.text ?? "") ?? 0) * (Int(txtCount.text ?? "") ?? 0))
            party?.plusPrice(price: (Int(txtPrice.text ?? "") ?? 0) * (Int(txtCount.text ?? "") ?? 0))
        }
        
        for i in 0..<(place?.enjoyer.count)! {
            if(place?.enjoyer[i].member == 1) {
                addMenuUser(user: place?.enjoyer[i])
            }
        }
        
        self.dismiss(animated: true)
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            //user()[userIndex!].member = value
            place?.enjoyer[userIndex!].member = value
        }
    }
    
}

extension AddMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (place?.enjoyer.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = place?.enjoyer[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMenuTableCell") as! AddMenuTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        cell.btnCheck?.setTitle("✅", for: .normal)
        
        cell.delegate = self
        
        return cell
    }
    
}

extension AddMenuViewController: TableViewCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        
        if(button?.title(for: .normal) != "🟩") {
            button?.setTitle("🟩", for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
        } else {
            button?.setTitle("✅", for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
        }
    }
    
}
