import UIKit
import RealmSwift

class AddPlaceViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtName: UITextField!
    
    override func viewDidLoad() {
        resetUserMemberDB()
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            party?.user[userIndex!].member = value
        }
    }
    
    func addPlaceUser(user:User?) {
        // 방금 추가한 장소 index
        var index: Int = (party?.place.count)!-1
        
        try! realm.write {
            party?.place[index].addEnjoyer(user: user!)
        }
    }
    
    func resetUserMemberDB() {
        for i in 0..<(party?.user.count)! {
            try! realm.write {
                party?.user[i].member = 1
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        try! realm.write {
            party?.addPlace(name: txtName.text, price: Int(txtPrice.text ?? "") ?? 0) // ?? 는 nil값일 때 디폴트 값 지정
        }
        
        for i in 0..<(party?.user.count)! {
            if(party?.user[i].member == 1) {
                addPlaceUser(user: party?.user[i])
            }
        }
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension AddPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let party = self.party {
            return party.user.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row: String?
        
        if let party = self.party {
            row = party.user[indexPath.row].name
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPlaceUserTableCell") as! AddPlaceUserTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        cell.btnCheck?.setTitle("✅", for: .normal)
        
        cell.delegate = self
        
        return cell
    }
}

extension AddPlaceViewController: AddPlaceUserTableCellDelegate {
    
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
