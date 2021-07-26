//
//  SignUpViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/06.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD
import Nuke
import SDWebImage


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextFIeld: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        guard let email = emailTextFIeld.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res,err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            res?.user.sendEmailVerification(completion: { (error) in
                if error == nil {
                    let alert = UIAlertController(title: "仮登録を行いました。", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func loginNextButton(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.layer.cornerRadius = 70
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkFirebase),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func checkFirebase() {
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { error in
                if error == nil {
                    print("USER読み込み開始１")
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        print("USER読み込み開始２")
                        let image = self.profileImageButton.imageView?.image ?? UIImage(named: "uniform2020")
                        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
                        HUD.show(.progress)
                        
                        let filename = NSUUID().uuidString
                        let storageRef = Storage.storage().reference().child(Const.ImagePath).child(filename)
                        
                        storageRef.putData(uploadImage, metadata: nil) { (matadata, err) in
                            if let err = err {
                                print("Firestorageへの情報の保存に失敗しました。\(err)")
                                HUD.hide()
                                return
                            }
                            
                            storageRef.downloadURL {(url, err) in
                                if let err = err{
                                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                                    HUD.hide()
                                    return
                                }
                                
                                guard let urlString = url?.absoluteString else { return }
                                self.createUserToFirestore(profileImageUrl: urlString)
                                
                            }
                        }
                    } else if Auth.auth().currentUser?.isEmailVerified == false {
                        let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
        
    }
    
    
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextFIeld.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = self.usernameTextField.text else { return }
        let docData = [
            "email": email,
            "username": username,
            "createdAt": Timestamp(),
            "profileImageUrl": profileImageUrl
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) {
            (err) in
            
            if let err = err {
                print("データベースへの保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            print("Firestoreへの情報の保存が成功しました。")
            HUD.hide()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

