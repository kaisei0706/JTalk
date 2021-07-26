//
//  LoginViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/12.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmailTextFIeld: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBAction func tappedLoginButton(_ sender: Any) {
        guard let email = loginEmailTextFIeld.text else { return }
        guard let password = loginPasswordTextField.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) {(res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            HUD.hide()
            print("ログインに成功しました。")
            self.dismiss(animated: true, completion: nil)
            // 投稿処理をキャンセルし、先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
