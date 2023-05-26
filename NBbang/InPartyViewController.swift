import UIKit
import RealmSwift

class InPartyViewController: UIViewController {
    let realm = try! Realm()
    var index:Int?
    let color = UIColor(hex: "#4364C9")
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        navigationSetting()
        
        if let i = index {
            navigationItem.title = party()[i].name
            navigationItem.title! += " ("+String(party()[i].user.count)+")"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.reloadData()
        if let i = index {
            navigationItem.title = party()[i].name
            navigationItem.title! += " ("+String(party()[i].user.count)+")"
        }
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
            titleLabel.text = party()[index!].name
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        let settleButton = UIButton(type: .custom)
        settleButton.setImage(UIImage(named: "icon_settle.png")?.withRenderingMode(.alwaysOriginal), for: .normal)
        settleButton.setTitle("정산", for: .normal)
        settleButton.titleLabel?.font = UIFont(name: "SeoulNamsanCM", size: 18)
        settleButton.sizeToFit() // 버튼 크기 조정
        settleButton.addTarget(self, action: #selector(settleButtonTapped), for: .touchUpInside)

        let settleBarButtonItem = UIBarButtonItem(customView: settleButton)
        navigationItem.rightBarButtonItem = settleBarButtonItem

    }
    
    @objc func settleButtonTapped() {
        
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func place() -> Results<Place> {
        return realm.objects(Place.self)
    }
    
    func addPlaceNsaveDB(name:String?, price: Int) {
        
        try! realm.write {
            realm.add(Place(name: name, totalPrice: price))
        }
    }
    
    func addPlace(name:String?, totalPrice:Int) {
        try! realm.write {
            party()[self.index!].addPlace(name: name, totalPrice: totalPrice)
        }
    }
    
    @IBAction func onInviteUser(_ sender: Any) {
        
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InviteUserViewController") as? InviteUserViewController else {
                    return
                }
        na.index = index
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    @IBAction func onAddPlace(_ sender: Any) {
        guard let du = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as? AddPlaceViewController else {
                    return
                }
        
        //du.index = indexPath.row
        //du.date = checkKey()
        du.party = party()[index!]
        
        du.modalPresentationStyle = .fullScreen
        self.present(du, animated: true)
        
//        let alert = UIAlertController(title: "장소 추가", message: "ex) 술집, 노래방, 편의점", preferredStyle: .alert)
//        alert.addTextField()
//        let ok = UIAlertAction(title: "추가", style: .default) { (ok) in
//
//            self.addPlace(name: alert.textFields?[0].text)
//            self.table.reloadData()
//        }
//
//        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
//
//        }
//
//        alert.addAction(cancel)
//        alert.addAction(ok)
//
//        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension InPartyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return party()[index!].place.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var row = party()[index!].place[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableCell") as! PlaceTableCell
        
        cell.lblPlaceName?.text = row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // 고정된 높이 값을 반환합니다.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPlaceViewController") as? InPlaceViewController else {
                    return
                }
        //na.index = indexPath.row
        na.place = party()[index!].place[indexPath.row]
        na.party = party()[index!]

        self.navigationController?.pushViewController(na, animated: true)
        
    }
    
}
