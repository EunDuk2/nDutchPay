import UIKit
import RealmSwift

class InPlaceViewController: UIViewController, UINavigationControllerDelegate {
    
    let realm = try! Realm()
    var party: Party?
    var place: Place?
    var index:Int?
    let color = UIColor(hex: "#B1B2FF")
    
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblPlaceEnjoyer: UILabel!
    @IBOutlet var table: UITableView!
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lblAddAlert: UILabel!
    @IBOutlet var btnCamera: UIButton!
    
    override func viewDidLoad() {
        navigationSetting()
        viewSetting()
        
        updateLabel()
        cameraSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabel()
        table.reloadData()
        if(place?.menu.count != 0) {
            lblAddAlert.isHidden = true
        } else {
            lblAddAlert.isHidden = false
        }
        cameraSetting()
    }
    
    func viewSetting() {
        viewLabel.layer.cornerRadius = 10
        viewLabel.clipsToBounds = true
        if(place?.menu.count != 0) {
            lblAddAlert.isHidden = true
        } else {
            lblAddAlert.isHidden = false
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
            titleLabel.text = place?.name
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let settingButtonImage = UIImage(named: "icon_setting3.png")
        let buttonSize = CGSize(width: 30, height: 30)
        UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let resizedImage = UIGraphicsImageRenderer(size: buttonSize).image { _ in
            settingButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let settingButton = UIBarButtonItem(title: "", image: resizedImage, target: self, action: #selector(settingButtonTapped))

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
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "SettleViewController") as? SettleViewController else {
                    return
                }
        na.party = self.party
        
        let navigationController = UINavigationController(rootViewController: na)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    @objc func settingButtonTapped() {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "EditPlaceViewController") as? EditPlaceViewController else {
            return
        }
        
        na.party = self.party
        na.place = self.place
        
        self.navigationController?.pushViewController(na, animated: true)
    }
    
    func cameraSetting() {
        if(place?.imageData == nil) {
            btnCamera.setImage(UIImage(named: "icon_camera1.png"), for: .normal)
        } else {
            btnCamera.setImage(UIImage(named: "icon_camera2.png"), for: .normal)
        }
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
    
    func showActionSheet() {
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
    
    @IBAction func onAddMenu(_ sender: Any) {
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "AddMenuViewController") as? AddMenuViewController else {
                    return
                }
        na.place = self.place
        na.party = self.party
        
        let navigationController = UINavigationController(rootViewController: na)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func onCamera(_ sender: Any) {
        if(place?.imageData == nil) {
            showActionSheet()
        } else {
            guard let na = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
                        return
                    }
            na.place = self.place
            
            self.navigationController?.pushViewController(na, animated: true)
        }
        
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

extension InPlaceViewController: UIImagePickerControllerDelegate {
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
    
    func saveImageToRealm(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        try! realm.write {
            place?.imageData = imageData
        }
    
        guard let na = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
                    return
                }
        na.place = self.place
        
        self.navigationController?.pushViewController(na, animated: true)
        }
}
