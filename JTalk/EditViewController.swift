//
//  EditViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/05/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD
import Nuke
import SDWebImage

class EditViewController: UIViewController {
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []

    @IBOutlet weak var EditImageButton: UIButton!
    @IBOutlet weak var editUsernameTextField: UITextField!
    @IBAction func editTappedProfileImageButton(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func editRegisterButton(_ sender: Any) {
        
        guard let username = self.editUsernameTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData = [
            "username": username,
        ] as [String : Any]
        
        let docData2 = [
            "name": username,
        ] as [String : Any]
        Firestore.firestore().collection("users").document(uid).updateData(docData) {
            (err) in
            
            if let err = err {
                print("データベースへの保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            print("Firestoreへの情報の保存が成功しました。")
            HUD.hide()
            let alert = UIAlertController(title: "名前の変更に成功しました。", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
        }
        
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid ).getDocuments{ (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
            self.postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            
            let counts : Int = self.postArray.count
            var count = 0
            
            while count < counts {
                let postData = self.postArray[count]
                Firestore.firestore().collection("posts").document(postData.id).updateData(docData2) {
                    (err) in
                    
                    if let err = err {
                        print("データベースへの保存に失敗しました。\(err)")
                        HUD.hide()
                        return
                    }
                }
                count += 1
                
                
            }
            
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EditImageButton.setTitle("", for: .normal)
        EditImageButton.clipsToBounds = true
        EditImageButton.layer.cornerRadius = 70
        EditImageButton.layer.borderWidth = 1
        EditImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        let uid = Auth.auth().currentUser?.uid
        
        
        Firestore.firestore().collection(Const.UserPath).document(uid!).getDocument() { (document, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            self.editUsernameTextField.text = document?.get("username") as? String
            
            if URL(string: document?.get("profileImageUrl") as! String) != nil {
                self.EditImageButton.sd_setBackgroundImage(with: URL(string: document?.get("profileImageUrl") as! String), for: .normal)
            }
            
        }

        // Do any additional setup after loading the view.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            EditImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            EditImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        EditImageButton.setTitle("", for: .normal)
        EditImageButton.imageView?.contentMode = .scaleAspectFill
        EditImageButton.contentHorizontalAlignment = .fill
        EditImageButton.contentVerticalAlignment = .fill
        EditImageButton.clipsToBounds = true
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
