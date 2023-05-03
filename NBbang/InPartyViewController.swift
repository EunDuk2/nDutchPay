import UIKit
import RealmSwift

class InPartyViewController: UIViewController {
    let realm = try! Realm()
    var index:Int?
    
    override func viewDidLoad() {
        navigationItem.title = party()[index!].name
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    @IBAction func onInviteUser(_ sender: Any) {
        
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InviteUserViewController") as? InviteUserViewController else {
                    return
                }
        na.index = index
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    
}
