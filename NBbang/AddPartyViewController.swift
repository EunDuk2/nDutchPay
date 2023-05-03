import UIKit

class AddPartyViewController: ViewController {
    
    @IBOutlet var partyName: UITextField!
    
    @IBAction func onSubmit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onAddParty(_ sender: Any) {
        if(partyName.text != "") {
            addPartyNsaveDB(name: partyName.text!)
            
            self.dismiss(animated: true)
        }
    }
    
}
