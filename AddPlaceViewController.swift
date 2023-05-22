import UIKit
import RealmSwift

class AddPlaceViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtName: UITextField!
    
    @IBOutlet var btnSubmit: UIBarButtonItem!
    
    override func viewDidLoad() {
        resetUserMemberDB()
        btnSubmit.isEnabled = false
        
        txtPrice.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(priceDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPrice)
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
    
    func addDefaultMenu(index: Int, totalPrice: Int?) {
        let tempList: List<User>? = party?.place[index].enjoyer
        try! realm.write {
            party?.place[index].setDefaultMenu(defaultMenu: Menu(name: "기타 메뉴", price: totalPrice!, count: 1, enjoyer: tempList))
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        try! realm.write {
            if(txtName.text == "") {
                party?.addPlace(name: "이름 없는 장소"+String((party?.place.count)!+1), totalPrice: Int(txtPrice.text ?? "") ?? 0)
            } else {
                party?.addPlace(name: txtName.text, totalPrice: Int(txtPrice.text ?? "") ?? 0)
            }
            party?.plusPrice(price: Int(txtPrice.text!)!)
        }
        
        for i in 0..<(party?.user.count)! {
            if(party?.user[i].member == 1) {
                addPlaceUser(user: party?.user[i])
            }
        }
        
        addDefaultMenu(index: (party?.place.count)!-1, totalPrice: Int(txtPrice.text ?? "") ?? 0)
        
        
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

extension AddPlaceViewController: UITextFieldDelegate {
    @objc private func priceDidChange(_ notification: Notification) {
            if let textField = notification.object as? UITextField {
                if let text = textField.text {
                    //checkName(text: text, textField: textField)
                    if(text == "" || Int(text) == 0) {
                        btnSubmit.isEnabled = false
                    } else {
                        btnSubmit.isEnabled = true
                    }
                }
            }
        }
}
