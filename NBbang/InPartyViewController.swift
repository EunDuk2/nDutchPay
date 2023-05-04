import UIKit
import RealmSwift

class InPartyViewController: UIViewController {
    let realm = try! Realm()
    var index:Int?
    
    override func viewDidLoad() {
        navigationItem.title = party()[index!].name
        navigationItem.title! += " ("+String(party()[index!].user.count)+")"
        
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    func place() -> Results<Place> {
        return realm.objects(Place.self)
    }
    
    func addPlaceNsaveDB(name:String?) {
        
        try! realm.write {
            realm.add(Place(name: name))
        }
    }
    
    func addPlace(name:String?) {
        try! realm.write {
            party()[self.index!].addParty(name: name)
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
        //addPlaceNsaveDB(name: "test")
        let alert = UIAlertController(title: "장소 추가", message: "ex) 술집, 노래방, 편의점", preferredStyle: .alert)
        alert.addTextField()
        let ok = UIAlertAction(title: "추가", style: .default) { (ok) in
            
            self.addPlace(name: alert.textFields?[0].text)
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in

        }

        alert.addAction(cancel)
        alert.addAction(ok)

        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension InPartyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place().count
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
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPartyViewController") as? InPartyViewController else {
                    return
                }
        na.index = indexPath.row

        self.navigationController?.pushViewController(na, animated: true)
        
    }
    
}
