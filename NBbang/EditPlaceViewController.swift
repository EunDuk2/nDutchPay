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
    
    override func viewDidLoad() {
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
    
    func delBeforeAlert() {
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
    
    @IBAction func onSubmit(_ sender: Any) {
        delBeforeAlert()
        changePlaceName()
    }
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "장소 삭제", message: "장소를 삭제하면 해당 장소의 모든 정보가 삭제됩니다.", preferredStyle: .alert)
        let clear = UIAlertAction(title: "삭제", style: .destructive) { (_) in
            try! self.realm.write {
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
            cell.btnCheck?.setTitle("✅", for: .normal)
            
            try! realm.write {
                party?.user[indexPath.row].member = 1
            }
        } else {
            cell.btnCheck?.setTitle("🟩", for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
}

extension EditPlaceViewController: TableViewCellDelegate {
    
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
}

//extension EditPlaceViewController: UITextFieldDelegate {
//    @objc private func priceDidChange(_ notification: Notification) {
//        if let textField = notification.object as? UITextField,
//           let text = textField.text {
//            // 입력된 값에서 숫자 이외의 문자 제거
//            let cleanedText = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//            
//            // 숫자 포맷팅을 위한 Formatter 생성
//            let numberFormatter = NumberFormatter()
//            numberFormatter.numberStyle = .decimal
//            numberFormatter.locale = Locale(identifier: "ko_KR")
//            
//            // 포맷팅된 결과 문자열
//            var formattedAmount = ""
//            
//            // 각각의 자릿수마다 3자리마다 포맷팅
//            for (index, char) in cleanedText.reversed().enumerated() {
//                if index != 0 && index % 3 == 0 {
//                    formattedAmount = "," + formattedAmount
//                }
//                formattedAmount = String(char) + formattedAmount
//            }
//            
//            // 포맷팅된 결과를 텍스트 필드에 적용
//            textField.text = formattedAmount
//            
//            // 정수로 변환된 값을 사용할 수 있도록 변수에 저장
//            if let integerValue = Int(cleanedText) {
//                // 정수로 변환된 값을 사용하여 작업 수행
//                // 예: integerValue를 다른 변수에 할당하거나 연산에 활용
//                print("정수 값:", integerValue)
//                price = integerValue
//            }
//            
//            // 버튼 활성/비활성 설정
//            btnSubmit.isEnabled = !cleanedText.isEmpty && Int(cleanedText) != 0
//        }
//    }
//}



