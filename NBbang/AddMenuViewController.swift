import UIKit
import RealmSwift

class AddMenuViewController: UIViewController, MenuAddCellDelegate {
    let realm = try! Realm()
    var place: Place?
    var party: Party?
    var intdex: Int?
    var allCheck: Bool = false
    let color = UIColor(hex: "#B1B2FF")
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtCount: UITextField!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var btnSubmit2: UIButton!
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        navigationSetting()
        self.hideKeyboardWhenTappedAround()
        
        resetUserMemberDB()
        btnSubmit.isEnabled = false
        btnSubmit2.isEnabled = false
        
        txtName.delegate = self
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
            titleLabel.text = "메뉴 추가"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let submitButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(submitButtonTapped))
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        cancelButton.setTitleTextAttributes(titleAttributes, for: .normal)
        submitButton.setTitleTextAttributes(titleAttributes, for: .normal)
        btnSubmit = submitButton
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = submitButton
    }
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    @objc func submitButtonTapped() {
        if(checkZeroUser(user: place!.enjoyer)) {
            let textPrice: Int = Int(txtPrice.text!)!
            let textCount: Int = Int(txtCount.text!)!
            
            let totalPrice: Int = textPrice * textCount
            
            preventTotalPriceExceedance(newPrice: totalPrice)
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
        
        let bottomLineName = UIView(frame: CGRect(x: 0, y: txtName.frame.size.height - 1, width: txtName.frame.size.width, height: 1))
        let bottomLinePrice = UIView(frame: CGRect(x: 0, y: txtPrice.frame.size.height - 1, width: txtPrice.frame.size.width, height: 1))
        let bottomLineCount = UIView(frame: CGRect(x: 0, y: txtCount.frame.size.height - 1, width: txtCount.frame.size.width, height: 1))
        
        let hexColor = "#B1B2FF"
        if let color = UIColor(hex: hexColor) {
            bottomLineName.backgroundColor = color
            bottomLinePrice.backgroundColor = color
            bottomLineCount.backgroundColor = color
        }
        
        txtName.addSubview(bottomLineName)
        txtPrice.addSubview(bottomLinePrice)
        txtCount.addSubview(bottomLineCount)
    }
    
    func resetUserMemberDB() {
        for i in 0..<(place?.enjoyer.count)! {
            try! realm.write {
                place?.enjoyer[i].member = 0
            }
        }
    }
    
    func addMenuUser(user:User?) {
        try! realm.write {
            place?.menu[(place?.menu.count)!-1].addEnjoyer(user: user!)
        }
        
    }
    
    func menuNameCount() -> Int {
        do {
            if let menues = place?.menu {
                let menuesWithName = menues.filter("name CONTAINS %@", "이름 없는 메뉴")
                let count = menuesWithName.count
                return count + 1
            } else {
                return 0
            }
        } catch {
            print("Realm 오류: \(error)")
            return 0
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
                place?.addMenu(name: "이름 없는 메뉴" + String(menuNameCount()), price: textPrice, count: textCount)
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
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            //user()[userIndex!].member = value
            place?.enjoyer[userIndex!].member = value
        }
    }
    
    
    // 전체 선택
    func setUserMemberDB() {
        for i in 0..<(place?.enjoyer.count)! {
            try! realm.write {
                place?.enjoyer[i].member = 1
            }
        }
    }
    func checkAllButtonBool() {
        var tempBool: Bool = true
        
        for i in 0..<(place?.enjoyer.count)! {
            if(place?.enjoyer[i].member == 0) {
                tempBool = false
            }
        }
        setBtnCheck(bool: tempBool)
    }
    func setBtnCheck(bool: Bool) {
        let image: UIImage?
        let title: String?
        let font = UIFont(name: "SeoulNamsanCM", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let textColor = color
        
        if(bool == true) {
            image = UIImage(named: "icon_check1.png")
            title = "전체 해제"
            
        } else {
            image = UIImage(named: "icon_notcheck1.png")
            title = "전체 선택"
        }

        btnCheck.setImage(image, for: .normal)
        btnCheck.setTitle(title, for: .normal)
        btnCheck.titleLabel?.font = font
        btnCheck.setTitleColor(textColor, for: .normal)
    }
    @IBAction func onAllCheck(_ sender: Any) {
        if(allCheck == false) {
            allCheck = true
            setUserMemberDB()
            setBtnCheck(bool: allCheck)
        } else {
            allCheck = false
            resetUserMemberDB()
            setBtnCheck(bool: allCheck)
        }
        table.reloadData()
    }
    @IBAction func onSubmit(_ sender: Any) {
        if(checkZeroUser(user: place!.enjoyer)) {
            let textPrice: Int = Int(txtPrice.text!)!
            let textCount: Int = Int(txtCount.text!)!
            
            let totalPrice: Int = textPrice * textCount
            
            preventTotalPriceExceedance(newPrice: totalPrice)
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
        
        if(allCheck == false) {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
}

extension AddMenuViewController: TableViewCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        
        if let image = button?.image(for: .normal), image != UIImage(named: "icon_notcheck.png") {
            button?.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 0)
            checkAllButtonBool()
        } else {
            button?.setImage(UIImage(named: "icon_check.png"), for: .normal)
            updateUserDB(userIndex: cellIndex, value: 1)
            checkAllButtonBool()
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
                    btnSubmit2.isEnabled = false
                } else {
                    btnSubmit.isEnabled = true
                    btnSubmit2.isEnabled = true
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
