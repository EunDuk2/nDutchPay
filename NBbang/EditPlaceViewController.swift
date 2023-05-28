import UIKit
import RealmSwift

class EditPlaceViewController: UIViewController {
    let realm = try! Realm()
    
    
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    
    var party: Party?
    var place: Place?
    var price: Int?
    let color = UIColor(hex: "#4364C9")
    
    override func viewDidLoad() {
        navigationSetting()
        
        self.hideKeyboardWhenTappedAround()
        resetUserMemberDB()
        printPlaceName()
        printPrice()
        
        txtPrice.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(priceDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPrice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetUserMemberDB()
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
            titleLabel.text = "장소 관리"
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
        EditBeforeAlert()
        changePlaceName()
    }
    func textFieldSetting() {
        txtName.borderStyle = .none
        txtPrice.borderStyle = .none
        
        txtName.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        txtPrice.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        
        let bottomLine1 = UIView(frame: CGRect(x: 0, y: txtName.frame.size.height - 1, width: txtName.frame.size.width, height: 1))
        let bottomLine2 = UIView(frame: CGRect(x: 0, y: txtPrice.frame.size.height - 1, width: txtPrice.frame.size.width, height: 1))
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLine1.backgroundColor = color
            bottomLine2.backgroundColor = color
        }
        txtName.addSubview(bottomLine1)
        txtPrice.addSubview(bottomLine2)
    }
    
    func resetUserMemberDB() {
        for i in 0..<(party?.user.count)! {
            try! realm.write {
                party?.user[i].member = 0
            }
        }
    }
    
    func user() -> Results<User> {
        return realm.objects(User.self)
    }
    
    func printPlaceName() {
        txtName.text = place?.name
    }
    
    func changePlaceName() {
        if (txtName.text != "") {
            try! realm.write {
                place?.name = txtName.text
            }
        }
    }
    
    func printPrice() {
        txtPrice.text = String((place?.totalPrice)!)
    }
    
    func calculateMenu() -> Bool{
        
        let totalPrice = Int(txtPrice.text!)!
        var allMenuPrice: Int = 0
        
        for i in 0..<(place?.menu.count)! {
            allMenuPrice += (place?.menu[i].totalPrice)!
        }
        
        if(allMenuPrice > totalPrice) {
            let alert = UIAlertController(title: "금액 경고", message: "입력하신 금액이 해당 장소의 모든 메뉴들의 총가격보다 낮습니다.\n메뉴들의 총가격: "+String(allMenuPrice)+" 원", preferredStyle: .alert)
            let clear = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(clear)
            
            self.present(alert, animated: true)
            
            return false
        } else {
            if (txtPrice.text != "" && totalPrice >= 0) {
                try! realm.write {
                    party?.plusPrice(price: (totalPrice - Int(place!.totalPrice)))
                    place?.totalPrice = totalPrice
                    place?.defaultMenu?.totalPrice = totalPrice
                    place?.defaultMenu?.totalPrice -= allMenuPrice
                }
            }
            
            return true
        }
    }
    
    func checkExistingUser(indexPathRow: Int) -> Bool {
        for i in 0..<(place?.enjoyer.count)! {
            if(party?.user[indexPathRow].id == place?.enjoyer[i].id) {
                return true
            }
        }
        return false
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            party?.user[userIndex!].member = value
        }
    }
    
    func delUser(userIndex: Int) {
        try! realm.write {
            if let user = party?.user[userIndex] {
                if let userIndexInPlace = place?.enjoyer.index(of: user) {
                    place?.enjoyer.remove(at: userIndexInPlace)
                    
                    for menu in user.menus {
                        if let userIndexInMenu = menu.enjoyer.index(of: user) {
                            menu.enjoyer.remove(at: userIndexInMenu)
                        }
                    }
                }
            }
        }
    }
    
    func addUser(userIndex: Int) {
        try! realm.write {
            let existingUser = realm.objects(User.self).filter("id == %@", party?.user[userIndex].id).first
                
                if let existingUser = existingUser {
                    place?.addEnjoyer(user: existingUser)
                } else {
                    
                }
        }
    }
    
    func sortUser() {
        try! realm.write {
            place?.enjoyer.sort(by: { $0.id! < $1.id! })
        }
    }
    
    func EditBeforeAlert() {
        let alert = UIAlertController(title: "장소 정보 변경", message: "장소 정보를 변경하시겠습니까?\n(해당 장소의 파티원 삭제 시 모든 메뉴에서 삭제됩니다.)", preferredStyle: .alert)
        let clear = UIAlertAction(title: "확인", style: .default) { (_) in
            
            if(self.calculateMenu() == false) {
                return
            }
            
            for i in 0..<(self.party?.user.count)! {
                if(self.party?.user[i].member == 0) {
                    if(self.checkExistingUser(indexPathRow: i)) {
                        self.delUser(userIndex: i)
                        self.sortUser()
                    }
                } else {
                    if(self.checkExistingUser(indexPathRow: i) == false) {
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
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "장소 삭제", message: "장소를 삭제하면 해당 장소의 모든 정보가 삭제됩니다.", preferredStyle: .alert)
        let clear = UIAlertAction(title: "삭제", style: .destructive) { [self] (_) in
            try! self.realm.write {
                self.party?.minusPrice(price: place!.totalPrice)
                self.realm.delete(self.place!)
            }
            if let navigationController = self.navigationController {
                    let viewControllers = navigationController.viewControllers
                    guard viewControllers.count >= 3 else {
                        // 이전 화면이 적어도 3개 이상 있어야 함
                        return
                    }
                    
                    let previousViewController = viewControllers[viewControllers.count - 3]
                    navigationController.popToViewController(previousViewController, animated: true)
                }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancel)
        alert.addAction(clear)
        
        self.present(alert, animated: true)
    }
    
}

extension EditPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (party?.user.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = party?.user[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteUserTableCell") as! InviteUserTableCell
        
        cell.index = indexPath.row
        cell.lblName?.text = row
        
        if(checkExistingUser(indexPathRow: indexPath.row) == true) {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: indexPath.row, value: 1)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
}

extension EditPlaceViewController: TableViewCellDelegate {
    
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

extension EditPlaceViewController: UITextFieldDelegate {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



