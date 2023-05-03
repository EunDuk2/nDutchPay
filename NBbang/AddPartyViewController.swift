import UIKit

class AddPartyViewController: ViewController {
    
    @IBOutlet var partyName: UITextField!
    
    @IBAction func onAddParty(_ sender: Any) {
        if(partyName.text != "") {
            addPartyNsaveDB(name: partyName.text!)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
