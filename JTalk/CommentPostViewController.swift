//
//  CommentPostViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/04/01.
//

import UIKit
import Firebase

class CommentPostViewController: UIViewController {
    
    var documentID = ""
    var id = ""
    var document: DocumentSnapshot?
    //         Firestoreのリスナー
    var listener: ListenerRegistration!
    
    @IBOutlet weak var commentPostTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        Firestore.firestore().collection(Const.PostPath).document(documentID).collection("post").document(id).getDocument { (snapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            self.document = snapshot
            self.commentPostTableView.reloadData()
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
