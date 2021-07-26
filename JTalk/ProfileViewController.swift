//
//  ProfileViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/05/19.
//

import UIKit
import Firebase
import Nuke

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var prouserImageView: UIImageView!
    @IBOutlet weak var prousernameLabel: UILabel!
    
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    //  Firestoreのリスナー
    var listener: ListenerRegistration!
    
    var listener2: ListenerRegistration!
    
    var selectedPostData: PostData?
    
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        profileTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        profileTableView.estimatedRowHeight = 1000  // セルの高さの見積もり
        profileTableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
        
        prouserImageView.layer.cornerRadius = 35
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser?.uid == nil {
            // ログインしていないときの処理
            print("ログインしてない")
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
        let uid = Auth.auth().currentUser?.uid
        
        
        Firestore.firestore().collection(Const.UserPath).document(uid!).getDocument() { (document, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            self.prousernameLabel.text = document?.get("username") as? String
            
            if let url = URL(string: document?.get("profileImageUrl") as? String ?? "") {
                Nuke.loadImage(with: url, into: self.prouserImageView)
            }
            
        }
        
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("uid", isEqualTo: uid ).order(by: "date", descending: true)
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
                    self.profileTableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                profileTableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener.remove()
        listener = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = profileTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        var isOwner = false
        if postArray[indexPath.row].uid == Auth.auth().currentUser?.uid {
            isOwner =  true
        }
        cell.setPostData(postArray[indexPath.row], isOwner: isOwner)
        cell.delegate = self
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        if cell.post0ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapicon(_ :)))
            cell.post0ImageView.addGestureRecognizer(tapGesture)
            cell.post0ImageView.isUserInteractionEnabled = true
        }
        
        if cell.post1ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap1icon(_ :)))
            cell.post1ImageView.addGestureRecognizer(tapGesture)
            cell.post1ImageView.isUserInteractionEnabled = true
        }
        
        if cell.post2ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap2icon(_ :)))
            cell.post2ImageView.addGestureRecognizer(tapGesture)
            cell.post2ImageView.isUserInteractionEnabled = true
        }
        
        if cell.post3ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap3icon(_ :)))
            cell.post3ImageView.addGestureRecognizer(tapGesture)
            cell.post3ImageView.isUserInteractionEnabled = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let commentViewController: CommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        let postData = postArray[indexPath.row]
        _ = self.profileTableView.indexPathForSelectedRow
        print("ポストデータID\(postData.id)")
        commentViewController.id = postData.id
        self.navigationController?.pushViewController(commentViewController, animated: true)
        profileTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
            print("DEBUG_PRINT: likeボタンがタップされました。")

            // タップされたセルのインデックスを求める
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.profileTableView)
            let indexPath = profileTableView.indexPathForRow(at: point)

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
    
    @objc func tapicon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: profileTableView)
        let tappedIndexPath = profileTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        print(tappedRow!)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[tappedRow!]

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(0)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected0Img = imageRef
        
        present(zoomInViewController, animated: true)
    }
    
    @objc func tap1icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: profileTableView)
        let tappedIndexPath = profileTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[tappedRow!]

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(1)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected1Img = imageRef
        
        present(zoomInViewController, animated: true)
        
    }
    
    @objc func tap2icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: profileTableView)
        let tappedIndexPath = profileTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[tappedRow!]

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(2)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected2Img = imageRef
        
        present(zoomInViewController, animated: true)
        
    }
    
    @objc func tap3icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: profileTableView)
        let tappedIndexPath = profileTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[tappedRow!]

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(3)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected3Img = imageRef
        
        present(zoomInViewController, animated: true)
        
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
