import UIKit
import RealmSwift

class EditMenuViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtCount: UITextField!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    
    let realm = try! Realm()
    var index: Int?
    var section: Int = 0
    var party: Party?
    var place: Place?
    var bool: Bool?
    let color = UIColor(hex: "#4364C9")
    
    override func viewDidLoad() {
        navigationSetting()
        
        self.hideKeyboardWhenTappedAround()
        resetUserMemberDB()
        printMenuName()
        printMenuPriceNCount()
        
        txtPrice.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(priceDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPrice)
        NotificationCenter.default.addObserver(self, selector: #selector(countDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtCount)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textFieldSetting()
    }
    
    @objc func navigationSetting() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = color
        navigationController!.navigationBar.standardAppearance = navigationBarAppearance
        navigationController!.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        if let titleView = navigationItem.titleView as? UILabel {
            titleView.textColor = .white
            titleView.font = UIFont(name: "SeoulNamsanCM", size: 21)
        } else {
            let titleLabel = UILabel()
            titleLabel.text = "메뉴 관리"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let submitButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(submitButtonTapped))
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        submitButton.setTitleTextAttributes(titleAttributes, for: .normal)
        btnSubmit = submitButton
        
        navigationItem.rightBarButtonItem = submitButton
    }
    @objc func submitButtonTapped() {
        if(checkZeroUser(user: (place?.menu[index!].enjoyer)!)) {
            EditBeforeAlert()
        }
    }
    func checkZeroUser(user:List<User>) -> Bool {
        for i in 0..<user.count {
            if(user[i].member == 1) {
                return true
            }
        }
        let alert = UIAlertController(title: "알림", message: "최소 한명 이상의 파티원을 선택해주세요.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true)
        return false
    }
    func textFieldSetting() {
        txtName.borderStyle = .none
        txtPrice.borderStyle = .none
        txtCount.borderStyle = .none
        
        txtName.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        txtPrice.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        txtCount.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        
        let bottomLine1 = UIView(frame: CGRect(x: 0, y: txtName.frame.size.height - 1, width: txtName.frame.size.width, height: 1))
        let bottomLine2 = UIView(frame: CGRect(x: 0, y: txtPrice.frame.size.height - 1, width: txtPrice.frame.size.width, height: 1))
        let bottomLine3 = UIView(frame: CGRect(x: 0, y: txtCount.frame.size.height - 1, width: txtCount.frame.size.width, height: 1))
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLine1.backgroundColor = color
            bottomLine2.backgroundColor = color
            bottomLine3.backgroundColor = color
        }
        txtName.addSubview(bottomLine1)
        txtPrice.addSubview(bottomLine2)
        txtCount.addSubview(bottomLine3)
    }
    
    func resetUserMemberDB() {
        for i in 0..<(place?.enjoyer.count)! {
            try! realm.write {
                place?.enjoyer[i].member = 0
            }
        }
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            place?.enjoyer[userIndex!].member = value
        }
    }
    
    func printMenuName() {
        if(section == 0) {
            txtName.text = "기타 메뉴"
            txtName.isEnabled = false
        }
        else if(section == 1) {
            txtName.text = place?.menu[index!].name
        }
    }
    
    func printMenuPriceNCount() {
        if(section == 0) {
            txtPrice.text = String((place?.defaultMenu?.totalPrice)!)
            txtPrice.isEnabled = false
            txtCount.isEnabled = false
        }
        else if(section == 1) {
            txtPrice.text = String((place?.menu[index!].price)!)
            txtCount.text = String((place?.menu[index!].count)!)
        }
    }
    
    func checkExistingUser(section: Int, indexPathRow: Int) -> Bool {
        
        if(section == 0) {
            for i in 0..<(place?.defaultMenu!.enjoyer.count)! {
                if(place?.enjoyer[indexPathRow].id == place?.defaultMenu!.enjoyer[i].id) {
                    return true
                }
            }
        }
        else if(section == 1) {
            for i in 0..<(place?.menu[index!].enjoyer.count)! {
                if(place?.enjoyer[indexPathRow].id == place?.menu[index!].enjoyer[i].id) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func delUser(userIndex: Int) {
        try! realm.write {
            if(section == 0) {
                if let user = place?.enjoyer[userIndex] {
                    if let userIndexInPlace = place?.defaultMenu!.enjoyer.index(of: user) {
                        place?.defaultMenu!.enjoyer.remove(at: userIndexInPlace)
                    }
                }
            }
            else if(section == 1) {
                if let user = place?.enjoyer[userIndex] {
                    if let userIndexInPlace = place?.menu[index!].enjoyer.index(of: user) {
                        place?.menu[index!].enjoyer.remove(at: userIndexInPlace)
                    }
                }
            }
        }
    }
    
    func addUser(userIndex: Int) {
        try! realm.write {
            if(section == 0) {
                let existingUser = realm.objects(User.self).filter("id == %@", place?.enjoyer[userIndex].id).first
                    
                    if let existingUser = existingUser {
                        place?.defaultMenu!.addEnjoyer(user: existingUser)
                    }
            }
            else if(section == 1) {
                let existingUser = realm.objects(User.self).filter("id == %@", place?.enjoyer[userIndex].id).first
                    
                    if let existingUser = existingUser {
                        place?.menu[index!].addEnjoyer(user: existingUser)
                    }
            }
        }
    }
    
    func sortUser() {
        try! realm.write {
            if(section == 0) {
                place?.defaultMenu!.enjoyer.sort(by: { $0.id! < $1.id! })
            }
            else if(section == 1) {
                place?.menu[index!].enjoyer.sort(by: { $0.id! < $1.id! })
            }
        }
    }
    
    func EditBeforeAlert() {
        let textPrice: Int = Int(txtPrice.text!)!
        let textCount: Int = Int(txtCount.text!)!
        
        let totalPrice: Int = textPrice * textCount
        
        let alert = UIAlertController(title: "메뉴 정보 변경", message: "메뉴 정보를 변경하시겠습니까?", preferredStyle: .alert)
        let clear = UIAlertAction(title: "확인", style: .default) { (_) in
        
            self.preventTotalPriceExceedance(newPrice: totalPrice)
            if(self.bool == false) {
                return
            }
            
            for i in 0..<(self.place?.enjoyer.count)! {
                
                if(self.place?.enjoyer[i].member == 0) {
                    if(self.checkExistingUser(section: self.section, indexPathRow: i)) {
                        self.delUser(userIndex: i)
                        self.sortUser()
                    }
                } else {
                    if(self.checkExistingUser(section: self.section, indexPathRow: i) == false) {
                        self.addUser(userIndex: i)
                        self.sortUser()
                    }
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
    }
    
    func updateMenu(name: String?, price: Int, count: Int, DmunuMinus: Bool) {
        try! realm.write {
            
            if(txtName.text != "") {
                place?.menu[index!].updateName(name: name)
            }
            place?.menu[index!].updateInfo(price: price, count: count)
            if(DmunuMinus == true) {
                place?.minusDmenuPrice(price: price * count)
            }
            
        }
    }
    
    // MARK: 메뉴 추가할 때 장소의 총 금액 넘으면 선택지 주고 메뉴 추가
    func preventTotalPriceExceedance(newPrice: Int) {
        
        var totalMenuPrice: Int = 0

        for i in 0..<(place?.menu.count)! {
            totalMenuPrice += (place?.menu[i].totalPrice)!
        }
        totalMenuPrice -= (place?.menu[index!].totalPrice)!
        totalMenuPrice += newPrice
        if(totalMenuPrice > place!.totalPrice) {
            // 장소 총 금액 초과
            // 알림으로 초과 됐다고 말하고
            let alert = UIAlertController(title: "금액 초과", message: "이 메뉴의 금액을 변경하면 장소의 총 사용 금액이 초과됩니다.\n메뉴를 변경하고 총 사용 금액을 늘리시겠습니까?", preferredStyle: .alert)
            let clear = UIAlertAction(title: "확인", style: .default) { [self] (_) in
                
                try! realm.write {
                    party?.plusPrice(price: newPrice - (place?.menu[index!].totalPrice)!)
                }
                self.bool = true
                updateMenu(name: txtName.text, price: Int((txtPrice.text)!)!, count: Int((txtCount.text)!)!, DmunuMinus: false)
                
                totalMenuPrice = 0
                for i in 0..<(place?.menu.count)! {
                    totalMenuPrice += (place?.menu[i].totalPrice)!
                }
                try! realm.write {
                    place?.totalPrice = totalMenuPrice
                    place?.defaultMenu?.totalPrice = place!.totalPrice - totalMenuPrice
                }
                self.navigationController?.popViewController(animated: true)
            }
            
            let cancel = UIAlertAction(title: "취소", style: .destructive) { (_) in
                self.bool = false
            }

            alert.addAction(cancel)
            alert.addAction(clear)

            self.present(alert, animated: true)
        } else {
            updateMenu(name: txtName.text, price: Int((txtPrice.text)!)!, count: Int((txtCount.text)!)!, DmunuMinus: false)
            totalMenuPrice = 0
            for i in 0..<(place?.menu.count)! {
                totalMenuPrice += (place?.menu[i].totalPrice)!
            }
            try! realm.write {
                place?.defaultMenu?.totalPrice = place!.totalPrice - totalMenuPrice
            }
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "메뉴 삭제", message: "메뉴를 삭제하면 해당 메뉴의 모든 정보가 삭제됩니다.", preferredStyle: .alert)
        let clear = UIAlertAction(title: "삭제", style: .destructive) { (_) in
            try! self.realm.write {
                self.place?.defaultMenu?.totalPrice += (self.place?.menu[self.index!].totalPrice)!
                self.realm.delete((self.place?.menu[self.index!])!)
            }
            
            self.navigationController?.popViewController(animated: true)
                
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
    }
    
}

extension EditMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (place?.enjoyer.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = place?.enjoyer[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteUserTableCell") as! InviteUserTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        
        if(checkExistingUser(section: self.section, indexPathRow: indexPath.row) == true) {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: indexPath.row, value: 1)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
    
}

extension EditMenuViewController: TableViewCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        if let image = button?.image(for: .normal), image != UIImage(named: "icon_notcheck.png") {
            button?.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
        } else {
            button?.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
        }
    }
    
}

extension EditMenuViewController: UITextFieldDelegate {
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
    @objc private func countDidChange(_ notification: Notification) {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
