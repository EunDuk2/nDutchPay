import UIKit

class InPlaceViewController: UIViewController {
    
    var party: Party?
    var place: Place?
    var index:Int?
    let color = UIColor(hex: "#4364C9")
    
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblPlaceEnjoyer: UILabel!
    @IBOutlet var table: UITableView!
    @IBOutlet var viewLabel: UIView!
    
    override func viewDidLoad() {
        navigationSetting()
        viewSetting()
        
        updateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabel()
        table.reloadData()
    }
    
    func viewSetting() {
        viewLabel.layer.cornerRadius = 10
        viewLabel.clipsToBounds = true
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
            titleLabel.text = place?.name
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let settingButtonImage = UIImage(named: "icon_setting3.png")?.withRenderingMode(.alwaysOriginal)
        let settingButton = UIBarButtonItem(title: "", image: settingButtonImage, target: self, action: #selector(settingButtonTapped))

        let settleButton = UIBarButtonItem(title: "정산", style: .plain, target: self, action: #selector(settleButtonTapped))
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        settleButton.setTitleTextAttributes(titleAttributes, for: .normal)

        navigationItem.rightBarButtonItems = [settingButton, settleButton]
        
        let backBarButtonItem = UIBarButtonItem(title: "메뉴 목록", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    @objc func settleButtonTapped() {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "SettleViewController") as? SettleViewController else {
                    return
                }
        du.party = self.party
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
    }
    @objc func settingButtonTapped() {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "EditPlaceViewController") as? EditPlaceViewController else {
            return
        }
        
        na.party = self.party
        na.place = self.place
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    func updateLabel() {
        lblTotalPrice.text = fc(amount: place!.totalPrice) + "(원)"
        
        var temp: String = String((place?.enjoyer.count)!) + "명("
        for i in 0..<(place?.enjoyer.count)! {
            if(i != (place?.enjoyer.count)!-1) {
                temp += (place?.enjoyer[i].name)! + ","
            } else {
                temp += (place?.enjoyer[i].name)!
            }
            
        }
        lblPlaceEnjoyer.text = temp + ")"
    }
    
    
    
    @IBAction func onAddMenu(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "AddMenuViewController") as? AddMenuViewController else {
                    return
                }
        du.place = self.place
        du.party = self.party
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
    }
    
}

extension InPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
       func numberOfSections(in tableView: UITableView) -> Int {
           return (place?.menu.count)!+1
       }
       
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
       let sections:[String] = ["추가되지 않은 메뉴", "추가된 메뉴"]
       
       if(section == 0) {
           return sections[0]
       } else if(section == 1) {
           return sections[1]
       }
       return ""
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        if indexPath.section == 0 {
                cell.lblName.text = place?.defaultMenu!.name
                
                var calEnjoyer: String? = "("
                for i in 0..<(place?.defaultMenu!.enjoyer.count)! {
                    if(i != (place?.defaultMenu!.enjoyer.count)!-1) {
                        calEnjoyer! += (place?.defaultMenu!.enjoyer[i].name)! + ", "
                    } else {
                        calEnjoyer! += (place?.defaultMenu!.enjoyer[i].name)!
                    }
                }
                calEnjoyer! += ")"
                cell.lblEnjoyer.text = calEnjoyer
            cell.lblTotalPrice.text = fc(amount: (place?.defaultMenu!.totalPrice)!) + "(원)"
        } else {
            let row1 = place?.menu[indexPath.section-1].name
            var row2: String = "("
            let row3 = place?.menu[indexPath.section-1].totalPrice
            
            for i in 0..<(place?.menu[indexPath.section-1].enjoyer.count)! {
                if(i != (place?.menu[indexPath.section-1].enjoyer.count)!-1) {
                    row2 += (place?.menu[indexPath.section-1].enjoyer[i].name)! + ", "
                } else {
                    row2 += (place?.menu[indexPath.section-1].enjoyer[i].name)!
                }
                
            }
            row2 += ")"
            
            cell.lblName.text = row1
            cell.lblEnjoyer.text = row2
            cell.lblTotalPrice.text = fc(amount: row3!) + "(원)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "EditMenuViewController") as? EditMenuViewController else {
                    return
                }
        
        na.party = self.party
        na.place = self.place
        
        if indexPath.section == 0 {
            
            na.section = 0
            
        }
        else {
            
            na.section = 1
            na.index = indexPath.section - 1
            
        }
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
