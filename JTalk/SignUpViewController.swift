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
    @IBOutlet weak var teamTextField: UITextField!
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
            
            let image = self.profileImageButton.imageView?.image ?? UIImage(named: "uniform2020")
            guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
            HUD.show(.progress)
            
            let uid = Auth.auth().currentUser?.uid
            let storageRef = Storage.storage().reference().child(Const.ImagePath).child((uid!) + ".jpg")
            
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
            
//            res?.user.sendEmailVerification(completion: { (error) in
//                if error == nil {
//                    let alert = UIAlertController(title: "仮登録を行いました。", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            })
        }
    }
    
    @IBAction func loginNextButton(_ sender: Any) {
    }
    
    var pickerView: UIPickerView = UIPickerView()
    let list: [String] = ["北海道コンサドーレ札幌", "ベガルタ仙台", "鹿島アントラーズ", "浦和レッズ", "柏レイソル", "FC東京", "川崎フロンターレ", "横浜F・マリノス", "横浜FC", "湘南ベルマーレ","清水エスパルス","名古屋グランパス","ガンバ大阪","セレッソ大阪","ヴィッセル神戸","サンフレッチェ広島","徳島ヴォルティス","アビスパ福岡","サガン鳥栖","大分トリニータ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker()
        
        profileImageButton.layer.cornerRadius = 70
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(checkFirebase),
//            name: UIApplication.didBecomeActiveNotification,
//            object: nil
//        )
    }
    
    func picker(){
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        
        // 決定・キャンセル用ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, spaceItem, doneItem], animated: true)
        
        // インプットビュー設定
        teamTextField.inputView = pickerView
        teamTextField.inputAccessoryView = toolbar
        
        // デフォルト設定
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
        
    }
    
    // 決定ボタンのアクション指定
    @objc func done() {
        teamTextField.endEditing(true)
        teamTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    // キャンセルボタンのアクション指定
    @objc func cancel(){
        teamTextField.endEditing(true)
    }
    // 画面タップでテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        teamTextField.endEditing(true)
    }
    
//    @objc func checkFirebase() {
//
//        if Auth.auth().currentUser != nil {
//            Auth.auth().currentUser?.reload(completion: { error in
//                if error == nil {
//                    print("USER読み込み開始１")
//                    if Auth.auth().currentUser?.isEmailVerified == true {
//                        print("USER読み込み開始２")
//                        let image = self.profileImageButton.imageView?.image ?? UIImage(named: "uniform2020")
//                        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
//                        HUD.show(.progress)
//
//                        let uid = Auth.auth().currentUser?.uid
//                        let storageRef = Storage.storage().reference().child(Const.ImagePath).child((uid!) + ".jpg")
//
//                        storageRef.putData(uploadImage, metadata: nil) { (matadata, err) in
//                            if let err = err {
//                                print("Firestorageへの情報の保存に失敗しました。\(err)")
//                                HUD.hide()
//                                return
//                            }
//
//                            storageRef.downloadURL {(url, err) in
//                                if let err = err{
//                                    print("Firestorageからのダウンロードに失敗しました。\(err)")
//                                    HUD.hide()
//                                    return
//                                }
//
//                                guard let urlString = url?.absoluteString else { return }
//                                self.createUserToFirestore(profileImageUrl: urlString)
//
//                            }
//                        }
//                    } else if Auth.auth().currentUser?.isEmailVerified == false {
//                        let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            })
//        }
//
//    }
//
    
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextFIeld.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = self.usernameTextField.text else { return }
        guard let teamname = self.teamTextField.text else { return }
        let docData = [
            "email": email,
            "username": username,
            "createdAt": Timestamp(),
            "profileImageUrl": profileImageUrl,
            "teamname": teamname
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

// ピッカーの初期設定
extension SignUpViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    // ピッカービューの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}

