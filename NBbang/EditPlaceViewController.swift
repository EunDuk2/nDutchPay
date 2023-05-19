import UIKit
import RealmSwift

class EditPlaceViewController: UIViewController {
    let realm = try! Realm()
    
    
    @IBOutlet var btnSubmit: UIBarButtonItem!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtPrice: UITextField!
    
    var party: Party?
    var place: Place?
    
    override func viewDidLoad() {
        printPlaceName()
        printPrice()
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
    
    func changeTotalPrice() {
        // 텍스트필드에 있는 돈으로 현재 장소 토탈금액 바꾸기
        // 근데 디폴트메뉴 빼고 존재하는 메뉴 가격 다 더해서 그것보다 크게 설정하게 해야함(추가로 메뉴 추가할 때 토탈 금액 못넘게 제한하기)
        // 가격 수정했을 때 디폴트 메뉴 업데이트
        var totalPrice = Int(txtPrice.text!)!
        
        if (txtPrice.text != "" && totalPrice >= 0) {
            try! realm.write {
                place?.totalPrice = totalPrice
                place?.defaultMenu?.totalPrice = totalPrice
                calculateMenu()
            }
        }
    }
    
    func calculateMenu() -> Bool{
        
        var totalPrice = Int(txtPrice.text!)!
        var allMenuPrice: Int = 0
        
        for i in 0..<(place?.menu.count)! {
            allMenuPrice += (place?.menu[i].totalPrice)!
        }
        print(allMenuPrice)
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
