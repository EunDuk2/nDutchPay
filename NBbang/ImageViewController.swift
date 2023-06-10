import UIKit
import RealmSwift

class ImageViewController: UIViewController, UINavigationControllerDelegate {
    let realm = try! Realm()
    var place: Place?
    let color = UIColor(hex: "#B1B2FF")
    var bool:Bool = false
    
    @IBOutlet var ivReceipt: UIImageView!
    @IBOutlet var btnDelete: UIButton!
    
    override func viewDidLoad() {
        navigationSetting()
        ivReceipt.image = UIImage(data: (place?.imageData)!)
        if(bool == true) {
            btnDelete.isHidden = true
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
            titleLabel.text = "영수증"
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "SeoulNamsanCM", size: 21)
            navigationItem.titleView = titleLabel
        }
        
        let shareButtonImage = UIImage(named: "icon_share1.png")
        let buttonSize = CGSize(width: 30, height: 30)
        UIGraphicsImageRenderer(size: buttonSize).image { _ in
            shareButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let resizedImage = UIGraphicsImageRenderer(size: buttonSize).image { _ in
            shareButtonImage!.draw(in: CGRect(origin: .zero, size: buttonSize))
        }
        let shareButton = UIBarButtonItem(title: "", image: resizedImage, target: self, action: #selector(shareButtonTapped))
        
        let settleButton = UIBarButtonItem(title: "변경", style: .plain, target: self, action: #selector(settleButtonTapped))
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SeoulNamsanCM", size: 18)!
        ]
        settleButton.setTitleTextAttributes(titleAttributes, for: .normal)
        
        navigationItem.rightBarButtonItems = [shareButton, settleButton]
        
        let backBarButtonItem = UIBarButtonItem(title: "메뉴 목록", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    @objc func shareButtonTapped() {

        var shareItems = [UIImage]()
        
        shareItems.append(UIImage(data: (place?.imageData)!)!)

        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.modalPresentationStyle = .fullScreen
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    @objc func settleButtonTapped() {
        showActionSheet()
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
            ivReceipt.image = UIImage(data: (place?.imageData)!)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 사진 선택 취소 시 호출되는 delegate 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alertController = UIAlertController(title: "사진 삭제", message: "사진을 삭제하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                // 삭제를 처리하는 로직을 여기에 작성합니다.
                try! self.realm.write {
                    self.place?.imageData = nil
                }
                self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
    }
    
}
extension ImageViewController: UIImagePickerControllerDelegate {
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
        }
}
