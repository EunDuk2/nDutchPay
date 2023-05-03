//
//  ViewController.swift
//  NBbang
//
//  Created by EUNSUNG on 2023/03/28.
//
import RealmSwift
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //saveDB()
        //updateDB()
        //getDB()
        //deleteDB(i: 0)
        //eraseDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tableView = table {
                tableView.reloadData()
            }
    }
    
    func party() -> Results<Party> {
        return realm.objects(Party.self)
    }
    
    
    
    func eraseDB() {
        // 아예 Realm 파일 삭제
                let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
                let realmURLs = [
                  realmURL,
                  realmURL.appendingPathExtension("lock"),
                  realmURL.appendingPathExtension("note"),
                  realmURL.appendingPathExtension("management")
                ]
                
                for URL in realmURLs {
                  do {
                    try FileManager.default.removeItem(at: URL)
                  } catch {
                    // handle error
                  }
                }

    }
    
    func addPartyNsaveDB(name:String?) {
        
        try! realm.write {
            realm.add(Party(name: name))
        }
    }

//    func getDB() {
//
//        lbltest.text = party()[1].user[0].name
//    }

//    func updateDB() {
//        let getParty = realm.objects(Party.self)
//        try! realm.write {
//            getParty[0].name = "eunduk"
//        }
//    }

    func deleteDB(i:Int) {
        //let getParty = realm.objects(Party.self)
        try! realm.write {
            realm.delete(party()[i])
        }
    }

    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func cnt() -> Int {
        return party().count
    }

    @IBAction func addParty(_ sender: Any) {
        print("test")
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "AddPartyViewController") as? AddPartyViewController else {
                    return
                }
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    @IBAction func onDeleteDB(_ sender: Any) {
//        try! realm.write {
//            realm.delete(party()[party().count-1])
//        }
        eraseDB()
        table.reloadData()
    }
    
}

extension ViewController:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cnt()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = party()[indexPath.row].name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyTableCell") as! PartyTableCell
        
        cell.partyName?.text = row
        cell.userList?.text = userList(index: indexPath.row)
        
        return cell
    }
    
    func userList(index: Int) -> String {
        var userList: String = ""
        userList += String(party()[index].user.count) + "명 ("
        for i in 0..<party()[index].user.count {
            if(i < party()[index].user.count-1) {
                userList += party()[index].user[i].name! + ","
            } else {
                userList += party()[index].user[i].name!
            }
            
        }
        userList += ")"
        return userList
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "InPartyViewController") as? InPartyViewController else {
                    return
                }
        na.index = indexPath.row

        //du.modalPresentationStyle = .fullScreen
        //self.present(du, animated: true)
        self.navigationController?.pushViewController(na, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // 고정된 높이 값을 반환합니다.
    }

}

