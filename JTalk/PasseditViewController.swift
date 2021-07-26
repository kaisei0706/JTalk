//
//  PasseditViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseAuth

class PasseditViewController: UIViewController {

    @IBOutlet weak var passEmailTextField: UITextField!
    
    @IBAction func passwordResettingButton(_ sender: Any) {
        passwordResetting()
        let alert = UIAlertController(title: "送信済み", message: "パスワード再設定メールを送信致しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let uid = Auth.auth().currentUser?.uid
        
        
        Firestore.firestore().collection(Const.UserPath).document(uid!).getDocument() { (document, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            self.passEmailTextField.text = document?.get("email") as? String
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func passwordResetting() {
        
        Auth.auth().languageCode = "ja_JP" // 日本語に変換
        guard let email = passEmailTextField.text else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if let err = err {
                print("再設定メールの送信に失敗しました。\(err)")
                return
            }
            print("再設定メールの送信に成功しました。")
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
