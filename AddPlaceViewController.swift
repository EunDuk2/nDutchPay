import UIKit
import RealmSwift

class AddPlaceViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    var allCheck: Bool = false
    let color = UIColor(hex: "#11009E")
    
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        navigationSetting()
        
        resetUserMemberDB()
        btnSubmit.isEnabled = false
        txtName.delegate = self
        txtPrice.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(priceDidChange(_:)),
                                                    name: UITextField.textDidChangeNotification,
                                                    object: txtPrice)
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
            titleLabel.text = "장소 추가"
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
        if(checkZeroUser(user: party!.user)) {
            try! realm.write {
                if(txtName.text == "") {
                    party?.addPlace(name: "이름 없는 장소" + String(placeNameCount()), totalPrice: Int(txtPrice.text ?? "") ?? 0)
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
        
        txtName.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        txtPrice.subviews.filter { $0 is UIView }.forEach { $0.removeFromSuperview() }
        
        let bottomLineName = UIView(frame: CGRect(x: 0, y: txtName.frame.size.height - 1, width: txtName.frame.size.width, height: 1))
        let bottomLinePrice = UIView(frame: CGRect(x: 0, y: txtPrice.frame.size.height - 1, width: txtPrice.frame.size.width, height: 1))
        
        let hexColor = "#4364C9"
        if let color = UIColor(hex: hexColor) {
            bottomLineName.backgroundColor = color
            bottomLinePrice.backgroundColor = color
        }
        
        txtName.addSubview(bottomLineName)
        txtPrice.addSubview(bottomLinePrice)
    }
    
    func updateUserDB(userIndex: Int?, value: Int) {
        try! realm.write {
            party?.user[userIndex!].member = value
        }
    }
    
    func placeNameCount() -> Int {
        do {
            if let places = party?.place {
                let placesWithName = places.filter("name CONTAINS %@", "이름 없는 장소")
                let count = placesWithName.count
                return count + 1
            } else {
                return 0
            }
        } catch {
            print("Realm 오류: \(error)")
            return 0
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
                party?.user[i].member = 0
            }
        }
    }
    
    func addDefaultMenu(index: Int, totalPrice: Int?) {
        let tempList: List<User>? = party?.place[index].enjoyer
        try! realm.write {
            party?.place[index].setDefaultMenu(defaultMenu: Menu(name: "기타 메뉴", price: totalPrice!, count: 1, enjoyer: tempList))
        }
    }
    
    func setUserMemberDB() {
        for i in 0..<(party?.user.count)! {
            try! realm.write {
                party?.user[i].member = 1
            }
        }
    }
    
    func checkAllButtonBool() {
        var tempBool: Bool = true
        
        for i in 0..<(party?.user.count)! {
            if(party?.user[i].member == 0) {
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
            image = UIImage(named: "icon_check.png")
            title = "전체 해제"
            
        } else {
            image = UIImage(named: "icon_notcheck.png")
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
        
        if(allCheck == false) {
            cell.btnCheck.setImage(UIImage(named: "icon_notcheck.png"), for: .normal)
        } else {
            cell.btnCheck.setImage(UIImage(named: "icon_check.png"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
}

extension AddPlaceViewController: AddPlaceUserTableCellDelegate {
    
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
