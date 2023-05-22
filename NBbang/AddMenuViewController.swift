import UIKit
import RealmSwift

class AddMenuViewController: UIViewController, MenuAddCellDelegate {
    let realm = try! Realm()
    var place: Place?
    var party: Party?
    var intdex: Int?
    
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
    
    // MARK: 메뉴 추가할 때 장소의 총 금액 넘으면 선택지 주고 메뉴 추가
    func preventTotalPriceExceedance(newPrice: Int) {
        
        var totalMenuPrice: Int = 0
        
        for i in 0..<(place?.menu.count)! {
            totalMenuPrice += (place?.menu[i].totalPrice)!
        }
        totalMenuPrice += newPrice
        if(totalMenuPrice > place!.totalPrice) {
            // 장소 총 금액 초과
            // 알림으로 초과 됐다고 말하고
            let alert = UIAlertController(title: "금액 초과", message: "이 메뉴를 추가하면 장소의 총 사용 금액이 초과됩니다.\n메뉴를 추가하고 총 사용 금액을 늘리시겠습니까?", preferredStyle: .alert)
            let clear = UIAlertAction(title: "확인", style: .default) { [self] (_) in
                try! realm.write {
                    party?.plusPrice(price: newPrice - (place?.defaultMenu!.totalPrice)!)
                    place?.totalPrice = totalMenuPrice
                    place?.defaultMenu?.price = place!.totalPrice - totalMenuPrice
                    place?.defaultMenu?.totalPrice = place!.totalPrice - totalMenuPrice
                }
                
                addMenu(DmunuMinus: false)
            }
            let cancel = UIAlertAction(title: "취소", style: .destructive) { (_) in
                
                
            }
            
            alert.addAction(cancel)
            alert.addAction(clear)
            
            self.present(alert, animated: true)
        } else {
            addMenu(DmunuMinus: true)
        }
    }
    
    func addMenu(DmunuMinus: Bool) {
        let textPrice: Int = Int(txtPrice.text!)!
        let textCount: Int = Int(txtCount.text!)!
        
        let totalPrice: Int = textPrice * textCount
        
        try! realm.write {
            if(txtName.text == "") {
                place?.addMenu(name: "이름 없는 메뉴"+String((place?.menu.count)!+1), price: textPrice, count: textCount)
            } else {
                place?.addMenu(name: txtName.text, price: textPrice, count: textCount)
            }
            if(DmunuMinus == true) {
                place?.minusDmenuPrice(price: totalPrice)
            }
        }
        
        for i in 0..<(place?.enjoyer.count)! {
            if(place?.enjoyer[i].member == 1) {
                addMenuUser(user: place?.enjoyer[i])
            }
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let textPrice: Int = Int(txtPrice.text!)!
        let textCount: Int = Int(txtCount.text!)!
        
        let totalPrice: Int = textPrice * textCount
        //addMenu()
        preventTotalPriceExceedance(newPrice: totalPrice)
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
