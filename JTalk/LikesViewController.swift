//
//  LikesViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/05/26.
//

import UIKit
import Firebase
import Nuke

class LikesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    //  Firestoreのリスナー
    var listener: ListenerRegistration!
    
    var selectedPostData: PostData?

    @IBOutlet weak var likesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likesTableView.delegate = self
        likesTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        likesTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        likesTableView.estimatedRowHeight = 1000  // セルの高さの見積もり
        likesTableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("likes", arrayContains: uid ).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
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
                    // TableViewの表示を更新する
                    self.likesTableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                likesTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = likesTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        var isOwner = false
        if postArray[indexPath.row].uid == Auth.auth().currentUser?.uid {
            isOwner =  true
        }
        cell.setPostData(postArray[indexPath.row], isOwner: isOwner)
        cell.delegate = self
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let commentViewController: CommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        let postData = postArray[indexPath.row]
        _ = self.likesTableView.indexPathForSelectedRow
        print("ポストデータID\(postData.id)")
        commentViewController.id = postData.id
        self.navigationController?.pushViewController(commentViewController, animated: true)
        likesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
            print("DEBUG_PRINT: likeボタンがタップされました。")

            // タップされたセルのインデックスを求める
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.likesTableView)
            let indexPath = likesTableView.indexPathForRow(at: point)

            // 配列からタップされたインデックスのデータを取り出す
            let postData = postArray[indexPath!.row]

            // likesを更新する
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                if postData.isLiked {
                    // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                    updateValue = FieldValue.arrayRemove([myid])
                } else {
                    // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                    updateValue = FieldValue.arrayUnion([myid])
                }
                // likesに更新データを書き込む
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["likes": updateValue])
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
