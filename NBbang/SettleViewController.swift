import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import RealmSwift

class SettleViewController: UIViewController, UINavigationControllerDelegate{
    let realm = try! Realm()
    var party: Party?
    var place: Place?
    var selectedIndexPath: IndexPath?
    let color = UIColor(hex: "#B1B2FF")
    var settleText: String = ""
    var pickAccount: String?
    var accountString:[String]?
    var cellIndex:Int?
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var table: UITableView!
    @IBOutlet var btnAccount: UIButton!
    @IBOutlet var lblRemainder: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        navigationSetting()
        placeUserMoneySetting()
        viewSetting()
        
        printInitLabel()
        plusUserMoney()
        lblRemainder.text = calRemainder()+"(원)"
        
        pickerView.isHidden = true
        toolBar.isHidden = true
        accountString = getAccount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.reloadData()
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
            titleLabel.text = "정산 내역"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let settingButtonImage = UIImage(named: "icon_share1.png")
        let buttonSize = CGSize(width: 30, height: 30)
        UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let resizedImage = UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let shareButton = UIBarButtonItem(title: "", image: resizedImage, target: self, action: #selector(shareButtonTapped))
        let submitButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(submitButtonTapped))
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        submitButton.setTitleTextAttributes(titleAttributes, for: .normal)
        
        navigationItem.leftBarButtonItem = shareButton
        navigationItem.rightBarButtonItem = submitButton
    }
    @objc func shareButtonTapped() {
        //var shareItems = [String]()

        //shareItems.append(writeSettleText())

        var shareItems = [Any]()

        // 텍스트 추가
        shareItems.append(writeSettleText())


        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.modalPresentationStyle = .fullScreen
        self.present(activityViewController, animated: true, completion: nil)
        
        //메세지 번호 자동입ㄹㄱ돼서 보내기
//        let message = writeSettleText()
//        var sms : String = "sms:01012341234"
//
////        // 메시지 내용이 있으면 전화번호 뒤에 &body=메시지를 붙이고 인코딩을 한다
////        if let msg = message[0] , !(msg as AnyObject).isEmpty {
////            sms = sms + "&body=" + msg
////        }
//
//        sms = sms + "&body=" + message
//
//        sms = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!   // 인코딩
//
//        // UIApplication.shared.open : 지정된 url을 비동기로 연다
//        UIApplication.shared.open( URL.init(string: sms)!, options: [:], completionHandler: nil )
//
    
    
    }
    func sharePhotoToKakaoTalk(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        guard let kakaoURL = URL(string: "kakaotalk://") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(kakaoURL) {
            let pasteboard = UIPasteboard.general
            pasteboard.setData(imageData, forPasteboardType: "public.jpeg")
            
            let alert = UIAlertController(title: nil, message: "카카오톡으로 사진을 공유하시겠습니까?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if let url = URL(string: "kakaotalk://sendimage?image=public.jpeg"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        } else {
            print("카카오톡 앱이 설치되어 있지 않습니다.")
        }
    }




    @objc func submitButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func placeUserMoneySetting() {
        try! realm.write {
            for i in 0..<(party?.user.count)! {
                party!.user[i].placeMoney = 0
            }
        }
    }
    
    func viewSetting() {
        viewLabel.layer.cornerRadius = 10
        viewLabel.clipsToBounds = true
    }
    
    func initMoney() {
        for i in 0..<(party?.user.count)! {
            try! realm.write {
                party?.user[i].money = 0
            }
        }
    }
    
    func plusUserMoney() {
        var menu: Menu?
        var count: Int
        
        initMoney()
        
        for i in 0..<(party?.place.count)! {
            // 장소 가져오고
            place = party?.place[i]
            
            let dMenuEnjoyerCount: Int = (place?.defaultMenu?.enjoyer.count)!
            for j in 0..<(dMenuEnjoyerCount) {
                try! realm.write {
                    place?.defaultMenu?.enjoyer[j].money += (place?.defaultMenu!.totalPrice)! / dMenuEnjoyerCount
                }
            }
            
            for j in 0..<(place?.menu.count)! {
                // 장소안에 메뉴랑 사용자 가져오고
                menu = place?.menu[j]
                count = menu!.count
                
                for k in 0..<(menu?.enjoyer.count)! {
                    try! realm.write {
                        menu?.enjoyer[k].money += (menu?.totalPrice)! / (menu?.enjoyer.count)!
                    }
                }
                
            }
        }
    }
    
    func printInitLabel() {
        lblName.text = party?.name
        lblPrice.text = fc(amount: party!.totalPrice) + "(원)"
        
        var users: String = String((party?.user.count)!)
        users += "명("
        for i in 0..<(party?.user.count)! {
            if(i != (party?.user.count)! - 1) {
                users += (party?.user[i].name!)! + ","
            } else {
                users += (party?.user[i].name!)!
            }
            
        }
        users += ")"
        
        lblUser.text = users
    }
    
    func calPlaceUserMoney(place: Place, i:Int) -> String{
        placeUserMoneySetting()
        var userMoney:Int = 0
        
        try! realm.write {
            userMoney = 0
            
            if(place.defaultMenu?.totalPrice != 0 ) {
                let defaultMoney = place.defaultMenu!.totalPrice / (place.defaultMenu?.enjoyer.count)!
                userMoney += defaultMoney
                
                for i in 0..<place.defaultMenu!.enjoyer.count {
                    place.defaultMenu!.enjoyer[i].placeMoney = userMoney
                    
                }
            }
            userMoney = 0
            for i in 0..<place.menu.count {
                let tempMoney = place.menu[i].totalPrice / place.menu[i].enjoyer.count
                userMoney += tempMoney
                for j in 0..<place.menu[i].enjoyer.count {
                    place.menu[i].enjoyer[j].placeMoney += userMoney
                }
            }
        }
        
        return fc(amount: place.enjoyer[i].placeMoney)
    }
    
    func calMenuUserMoney(menu: Menu, i: Int) -> String{
        let money = menu.totalPrice / menu.enjoyer.count
        return fc(amount: money)
    }
    
    func addAccount(account: String) {
        try! realm.write {
            party?.addAccount(account: account)
        }
    }
    
    func updateAccount(account: String, index: Int) {
        try! realm.write {
            party?.account[index] = account
        }
    }
    
    func calRemainder() -> String {
        var totalPrice: Int = party!.totalPrice
        
        for i in 0..<party!.user.count {
            totalPrice -= (party?.user[i].money)!
        }
        
        return String(totalPrice)
    }
    
    func writeSettleText() -> String {
        
        settleText = "🎉 " + (party?.name)! + "\n"
        settleText += "파티 총 사용금액: " + fc(amount: party!.totalPrice) + "(원)\n"
        if(calRemainder() != "0") {
            settleText += "정산 후 잔돈: " + calRemainder() + "(원)\n"
        }
        settleText += "\n🙆‍♂️🙆‍♀️ 파티원 정산 (" + String((party?.user.count)!) + "명)\n"
        for i in 0..<(party?.user.count)! {
            settleText += (party?.user[i].name)! + "(" + fc(amount: (party?.user[i].money)!) + "원)\n"
        }
        
        if(party?.account.count != 0) {
            settleText += "\n💰 계좌정보:\n"
            for i in 0..<(party?.account.count)! {
                settleText += (party?.account[i])! + "\n"
            }
        }
        
        settleText += "\n"
        for i in 0..<(party?.place.count)! {
            settleText += "🏠 장소: " + (party?.place[i].name)! + "(" + fc(amount: (party?.place[i].totalPrice)!) + "원)\n"
            var placeText: String = "["
            for j in 0..<(party?.place[i].enjoyer.count)! {
                placeText += (party?.place[i].enjoyer[j].name)!
                placeText += "("
                placeText += calPlaceUserMoney(place: (party?.place[i])!, i: j)
                placeText += "원)"
            }
            placeText += "]\n"
            settleText += placeText
            
            var menuText:String = "["
            if(party?.place[i].menu.count != 0) {
                settleText += "🍔🍰 메뉴:\n"
                settleText += "-" + (party?.place[i].defaultMenu?.name)!
                settleText += "(" + fc(amount: (party?.place[i].defaultMenu?.totalPrice)!) + "원)\n"
                
                for j in 0..<(party?.place[i].defaultMenu?.enjoyer.count)! {
                    menuText += (party?.place[i].defaultMenu?.enjoyer[j].name)! + "("
                    menuText += calMenuUserMoney(menu: (party?.place[i].defaultMenu)!, i: j) + "원)"
                }
                
                menuText += "]\n"
                settleText += menuText
            }
            menuText = ""
            for j in 0..<(party?.place[i].menu.count)! {
                menuText += "\n-" + (party?.place[i].menu[j].name)!
                menuText += "(" + fc(amount: (party?.place[i].menu[j].totalPrice)!) + "원)\n["
                for k in 0..<(party?.place[i].menu[j].enjoyer.count)! {
                    menuText += (party?.place[i].menu[j].enjoyer[k].name)! + "("
                    menuText += calMenuUserMoney(menu: (party?.place[i].menu[j])!, i: k) + "원)"
                }
                menuText += "]\n"
            }
            settleText += menuText + "\n"
        }
        
        return settleText
    }
    
    @IBAction func onAccount(_ sender: Any) {
        showActionSheet()
    }
    @IBAction func onPickerSubmit(_ sender: Any) {
        self.addAccount(account: pickAccount!)
        self.table.reloadData()
        
        pickerView.isHidden = true
        toolBar.isHidden = true
    }
    @IBAction func onCancel(_ sender: Any) {
        pickerView.isHidden = true
        toolBar.isHidden = true
    }
    func showActionSheet() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let newAccountAction = UIAlertAction(title: "새로운 계좌 추가", style: .default) { _ in
            // "새로운 계좌 추가" 선택 시 수행할 동작
            let alert = UIAlertController(title: "계좌 추가", message: "송금 받을 계좌 정보를 입력해 주세요.", preferredStyle: .alert)
            alert.addTextField { (bank) in
                bank.placeholder = "은행이름(필수 입력)"
            }
            alert.addTextField { (account) in
                account.placeholder = "계좌번호(필수 입력)"
                account.keyboardType = .numberPad
            }
            alert.addTextField { (user) in
                user.placeholder = "예금주"
            }

            let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
                if(alert.textFields?[0].text != "" && alert.textFields?[1].text != "") {
                    var accouontText = (alert.textFields?[0].text)! + " "
                    accouontText += (alert.textFields?[1].text)!
                    if(alert.textFields?[2].text != "") {
                        accouontText += " (" + (alert.textFields?[2].text)! + ")"
                    }
                    
                    self.addAccount(account: accouontText)
                    self.table.reloadData()
                    self.accountString = self.getAccount()
                    self.pickerView.reloadAllComponents()
                } else {
                    let alert = UIAlertController(title: "알림", message: "은행과 계좌번호는 필수 입력입니다.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default)
                    
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true)
                }
                
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in

            }

            alert.addAction(cancel)
            alert.addAction(ok)

            self.present(alert, animated: true, completion: nil)
        }

        let existingAccountAction = UIAlertAction(title: "기존 계좌 추가", style: .default) { [self] _ in
            // "기존 계좌 추가" 선택 시 수행할 동작
            // 이 부분에 원하는 동작을 구현하세요
            
            if(getAccount().count == 0) {
                let alert = UIAlertController(title: "알람", message: "등록된 계좌가 없습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                pickerView.isHidden = false
                toolBar.isHidden = false
            }
            
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alertController.addAction(newAccountAction)
        alertController.addAction(existingAccountAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func getAccount() -> Array<String> {
        var accounts = Set<String>()

        // Party 객체들의 account 속성을 Set에 추가
        for party in realm.objects(Party.self) {
            accounts.formUnion(party.account)
        }
        return Array(accounts)
    }
}

extension SettleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // 선택한 항목을 출력
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedItem = accountString![row]
            pickAccount = selectedItem
            print("선택한 항목: \(selectedItem)")
        }
        
        // MARK: - UIPickerViewDataSource
        
        // 컴포넌트(열)의 개수
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1 // 1개의 열만 사용
        }
        
        // 컴포넌트(열)별 항목의 개수
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return accountString!.count
        }
        
        // 컴포넌트(열)의 각 항목의 내용 설정
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return accountString![row]
        }
}

extension SettleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (party?.place.count)!+2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sections:[String] = ["파티원 정산", "장소 및 메뉴 세부사항", "계좌 정보"]
        
        if(section == 0) {
            return sections[0]
        } else if(section == 1) {
            return sections[1]
        } else if(section == (party?.place.count)!+1) {
            return sections[2]
        }
            return ""
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if(section == 0 ) {
                return (party?.user.count)!
            }
            else if(section == (party?.place.count)!+1) {
                return (party?.account.count)!
            }
            else {
                return 1
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if(indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettleUserTableCell") as! SettleUserTableCell
                
                let row1 = party?.user[indexPath.row].name
                let row2 = party?.user[indexPath.row].money
                
                cell.lblName.text = row1
                cell.lblPrice.text = fc(amount: row2!) + " (원)"
                
                return cell
            }
            else if(indexPath.section == (party?.place.count)!+1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableCell") as! AccountTableCell
                
                cell.lblAccount.text = party?.account[indexPath.row]
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettlePlaceTableCell") as! SettlePlaceTableCell
                
                let row1 = (party?.place[indexPath.section-1].name)! + "(" + String((party?.place[indexPath.section-1].enjoyer.count)!) +  "), "
                let row2 = fc(amount: (party?.place[indexPath.section-1].totalPrice)!) + "(원)"
                var row3:String = ""
                
                for i in 0..<(party?.place[indexPath.section-1].enjoyer.count)! {
                    row3 += (party?.place[indexPath.section-1].enjoyer[i].name)!
                    row3 += "("
                    row3 += calPlaceUserMoney(place: (party?.place[indexPath.section-1])!, i: i)
                    row3 += "원)"
                }
                cell.delegate = self
                cell.index = indexPath.section-1
                cell.place = self.place
                cell.party = self.party
                cell.lblName.text = row1 + row2
                cell.lblUsers.text = row3
                if(party?.place[indexPath.section-1].imageData == nil) {
                    cell.btnCamera.setImage(UIImage(named: "icon_camera1.png"), for: .normal)
                } else {
                    cell.btnCamera.setImage(UIImage(named: "icon_camera2.png"), for: .normal)
                }
                
                return cell
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if(indexPath.section != 0 && indexPath.section != (party?.place.count)!+1) {
                tableView.deselectRow(at: indexPath, animated: true)
                if selectedIndexPath == indexPath {
                    selectedIndexPath = nil // 선택한 셀이 이미 있는 경우 해제
                    
                } else {
                    selectedIndexPath = indexPath // 선택한 셀의 인덱스 저장
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
                        let currentOffset = tableView.contentOffset
                        let newOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + CGFloat((party?.place[indexPath.section-1].menu.count)!)*CGFloat((indexPath.section))*30)
                        tableView.setContentOffset(newOffset, animated: true)
                    }
                }
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            else if(indexPath.section == (party?.place.count)!+1) {
                let alert = UIAlertController(title: "계좌 수정", message: "송금 받을 계좌 정보를 입력해 주세요.", preferredStyle: .alert)
                alert.addTextField { (bank) in
                         bank.placeholder = "은행이름(필수 입력)"
                }
                alert.addTextField { (account) in
                         account.placeholder = "계좌번호(필수 입력)"
                }
                alert.addTextField { (user) in
                         user.placeholder = "예금주"
                }
                
                if let (bank, account, user) = splitText(text: (party?.account[indexPath.row])!) {
                    alert.textFields?[0].text = bank
                    alert.textFields?[1].text = account
                    alert.textFields?[2].text = user
                }
                

                let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
                    if(alert.textFields?[0].text != "" && alert.textFields?[1].text != "") {
                        var accouontText = (alert.textFields?[0].text)! + " "
                        accouontText += (alert.textFields?[1].text)!
                        if(alert.textFields?[2].text != "") {
                            accouontText += " (" + (alert.textFields?[2].text)! + ")"
                        }
                        
                        self.updateAccount(account: accouontText, index: indexPath.row)
                        self.table.reloadData()
                    } else {
                        let alert = UIAlertController(title: "알림", message: "은행과 계좌번호는 필수 입력입니다.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "확인", style: .default)
                        
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true)
                    }
                    
                }

                let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in

                }

                alert.addAction(cancel)
                alert.addAction(ok)

                self.present(alert, animated: true, completion: nil)
            }
            
        }
    
    func splitText(text: String) -> (String, String, String?)? {
        let components = text.components(separatedBy: " ")
        if components.count >= 2 {
            let firstPart = components[0]
            let secondPart = components[1]
            var thirdPart: String?
            if components.count >= 3 {
                thirdPart = components[2].isEmpty ? nil : components[2]
            }
            return (firstPart, secondPart, thirdPart)
        }
        return nil
    }
        
    // 테이블 뷰의 셀 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section != 0 && indexPath.section != (party?.place.count)!+1) {
            if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
                let menuCount = party?.place[indexPath.section-1].menu.count ?? 0
                let menuHeight = CGFloat(150 * (menuCount+1))
                let totalHeight = 70 + menuHeight
                return min(totalHeight, 400)
            }
            return 70
        }
        return 44
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 25
        }
        return -1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        }
        return 10
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section == (party?.place.count)!+1) {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "삭제") { (action, indexPath) in
                self.deleteItem(at: indexPath)
            }
            return [deleteAction]
        } else {
            return nil
        }
        
    }
    
    func deleteItem(at indexPath: IndexPath) {
        try! realm.write {
            party?.account.remove(at: indexPath.row)
        }
        table.reloadData()
    }

}

extension SettleViewController: SettlePlaceTableCellDelegate {
    
    func didTapButton(cellIndex: Int?, button: UIButton?) {
        self.cellIndex = cellIndex
        if(party?.place[cellIndex!].imageData == nil) {
            showCameraActionSheet()
        } else {
            guard let na = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
                        return
                    }
            na.place = self.party?.place[cellIndex!]
            na.bool = true
            
            let backBarButtonItem = UIBarButtonItem(title: "정산 내역", style: .plain, target: self, action: nil)
            navigationItem.backBarButtonItem = backBarButtonItem
            self.navigationController?.pushViewController(na, animated: true)
        }
    }
    func showCameraActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 사진 촬영 액션
        let takePhotoAction = UIAlertAction(title: "사진 촬영", style: .default) { _ in
            self.openCamera()
        }
        
        // 앨범에서 가져오기 액션
        let choosePhotoAction = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            self.openPhotoLibrary()
        }
        
        // 취소 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 액션 추가
        alertController.addAction(takePhotoAction)
        alertController.addAction(choosePhotoAction)
        alertController.addAction(cancelAction)
        
        // 액션 시트 표시
        present(alertController, animated: true, completion: nil)
    }
    
}

extension SettleViewController: UIImagePickerControllerDelegate {
    // 카메라 열기
    func openCamera() {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("카메라를 사용할 수 없습니다.")
        }
    }
    
    // 앨범 열기
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("앨범에 접근할 수 없습니다.")
        }
    }
    
    // 사진 선택 완료 시 호출되는 delegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            //imageView.image = selectedImage
            saveImageToRealm(image: selectedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 사진 선택 취소 시 호출되는 delegate 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImageToRealm(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        try! realm.write {
            party?.place[cellIndex!].imageData = imageData
        }
    
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
                    return
                }
        na.place = self.party?.place[cellIndex!]
        na.bool = true
        
        let backBarButtonItem = UIBarButtonItem(title: "정산 내역", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationController?.pushViewController(na, animated: true)
        }
}
