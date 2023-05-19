import UIKit
import RealmSwift

class AddMenuViewController: UIViewController, MenuAddCellDelegate {
    let realm = try! Realm()
    var place: Place?
    var party: Party?
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtCount: UITextField!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    
    override func viewDidLoad() {
        resetUserMemberDB()
        
        btnSubmit.isEnabled = false
        
        txtPrice.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(priceDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPrice)
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
    
    // MARK: 메뉴 추가할 때 장소 총 금액 넘으면 선택지 주고 메뉴 추가
    func preventTotalPriceExceedance() {
        
    }
    
    func addMenu() {
        let textPrice: Int = Int(txtPrice.text!)!
        let textCount: Int = Int(txtCount.text!)!
        
        let totalPrice: Int = textPrice * textCount
        
        try! realm.write {
            if(txtName.text == "") {
                place?.addMenu(name: "이름 없는 메뉴"+String((place?.menu.count)!+1), price: textPrice, count: textCount)
            } else {
                place?.addMenu(name: txtName.text, price: textPrice, count: textCount)
            }
            party?.plusPrice(price: totalPrice)
            place?.minusDmenuPrice(price: totalPrice)
        }
        
        for i in 0..<(place?.enjoyer.count)! {
            if(place?.enjoyer[i].member == 1) {
                addMenuUser(user: place?.enjoyer[i])
            }
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        addMenu()
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

extension AddMenuViewController: UITextFieldDelegate {
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
