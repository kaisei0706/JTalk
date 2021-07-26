//
//  EmailEditViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/07/14.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class EmailEditViewController: UIViewController {
    
    

    @IBAction func emailSendingButton(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        
        Auth.auth().currentUser?.updateEmail(to: email) { (err) in
            
            if let err = err {
                print("メールアドレスの変更に失敗しました。\(err)")
                HUD.hide()
                return
            }
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                if error == nil {
                    let alert = UIAlertController(title: "仮登録を行いました。", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkFirebase),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // Do any additional setup after loading the view.
    }
    
    @objc func checkFirebase() {
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { error in
                if error == nil {
                    print("USER読み込み開始１")
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        print("認証完了")
                        self.navigationController?.popViewController(animated: true)
                        
                    } else if Auth.auth().currentUser?.isEmailVerified == false {
                        let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
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

}
