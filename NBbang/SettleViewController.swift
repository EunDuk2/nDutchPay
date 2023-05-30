import UIKit
import RealmSwift

class SettleViewController: UIViewController {
    let realm = try! Realm()
    var party: Party?
    var place: Place?
    var selectedIndexPath: IndexPath?
    let color = UIColor(hex: "#4364C9")
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        navigationSetting()
        viewSetting()
        
        printInitLabel()
        plusUserMoney()
        
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
        
        let shareButtonImage = UIImage(named: "icon_share1.png")?.withRenderingMode(.alwaysOriginal)
        let shareButton = UIBarButtonItem(title: "", image: shareButtonImage, target: self, action: #selector(shareButtonTapped))
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
        var shareItems = [String]()
        
        shareItems.append("test")

        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    @objc func submitButtonTapped() {
        self.dismiss(animated: true)
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
        var userMoney:Int = 0
        
        try! realm.write {
            userMoney = 0
            
            if(place.defaultMenu?.totalPrice != 0 ) {
                let defaultMoney = place.defaultMenu!.totalPrice / (place.defaultMenu?.enjoyer.count)!
                userMoney += defaultMoney
                
                for i in 0..<place.enjoyer.count {
                    place.enjoyer[i].placeMoney = userMoney
                }
            }
            
            
            for i in 0..<place.menu.count {
                let tempMoney = place.menu[i].totalPrice / place.menu[i].enjoyer.count
                userMoney += tempMoney
                for j in 0..<place.menu[i].enjoyer.count {
                    place.menu[i].enjoyer[j].placeMoney = userMoney
                }
            }
        }
        
        return fc(amount: place.enjoyer[i].placeMoney)
    }
    
}

extension SettleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (party?.place.count)!+1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sections:[String] = ["파티원 정산", "장소 및 메뉴 세부사항"]
        
        if(section == 0) {
            return sections[0]
        } else if(section == 1) {
            return sections[1]
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0 ) {
            return (party?.user.count)!
        } else {
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
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettlePlaceTableCell") as! SettlePlaceTableCell
            
            let row1 = (party?.place[indexPath.section-1].name)! + "(" + String((party?.place[indexPath.section-1].enjoyer.count)!) +  "), "
            let row2 = String((party?.place[indexPath.section-1].totalPrice)!) + "(원)"
            var row3:String = ""
            
            for i in 0..<(party?.place[indexPath.section-1].enjoyer.count)! {
                row3 += (party?.place[indexPath.section-1].enjoyer[i].name)!
                row3 += "("
                row3 += calPlaceUserMoney(place: (party?.place[indexPath.section-1])!, i: i)
                row3 += "원)"
            }
            
            cell.index = indexPath.section-1
            cell.place = self.place
            cell.party = self.party
            cell.lblName.text = row1 + row2
            cell.lblUsers.text = row3
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section != 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil // 선택한 셀이 이미 있는 경우 해제
                
            } else {
                selectedIndexPath = indexPath // 선택한 셀의 인덱스 저장
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    let currentOffset = tableView.contentOffset
                    let newOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + 100)
                    tableView.setContentOffset(newOffset, animated: true)
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
            
    }
        
        // 테이블 뷰의 셀 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 0 {
            if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
                let menuCount = party?.place[indexPath.row].menu.count ?? 0
                let menuHeight = CGFloat(130 * (menuCount+1))
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
    
}


