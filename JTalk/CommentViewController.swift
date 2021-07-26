//
//  CommentViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/26.
//

import UIKit
import Firebase
import Nuke

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentHeaderFooterViewDelegate {
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    var commentBarButtonItem: UIBarButtonItem!
    
    var documentID = ""
    var id = ""
    var document: DocumentSnapshot?
    //         Firestoreのリスナー
    
    var commentArray: [CommentData] = []
    var listener: ListenerRegistration!
    var listener2: ListenerRegistration!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        commentBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "message"), style: .done, target: self, action: #selector(addBarButtonTapped(_:)))
        
//        self.navigationItem.rightBarButtonItems = [commentBarButtonItem]
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        
        let xib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(xib, forCellReuseIdentifier: "CommentTableViewCell")
        
        commentTableView.sectionHeaderHeight = UITableView.automaticDimension
        commentTableView.estimatedSectionHeaderHeight = 50
        // ヘッダーを登録する
        let nib = UINib(nibName: "CommentHeaderFooterView", bundle: nil)
        commentTableView.register(nib, forHeaderFooterViewReuseIdentifier: "CommentHeaderFooterView")
        
        // Do any additional setup after loading the view.
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        
        if listener2 == nil {
            let countsRef = Firestore.firestore().collection(Const.PostPath).document(id)
            listener2 = countsRef.addSnapshotListener() { (snapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                
                self.document = snapshot
                self.commentTableView.reloadData()
            }
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                
                let postsRef =
                    Firestore.firestore().collection(Const.PostPath).document(self.id).collection("comments").order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.commentArray = querySnapshot!.documents.map { document in
                        let commentData = CommentData(document: document)
                        return commentData
                    }
                    self.commentTableView.reloadData()
                }
                self.commentTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.setPostData(commentArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommentHeaderFooterView") as! CommentHeaderFooterView
        
        headerFooterView.delegate2 = self
        
        if document == nil {
            return headerFooterView
        } else {
            
        var isOwner = false
        if document?.get("uid") as? String == Auth.auth().currentUser?.uid {
            isOwner =  true
        }
        
        let documents = PostData(document: document!)
        
        headerFooterView.setup(documents, isOwner: isOwner)
        // セル内のボタンのアクションをソースコードで設定する
        headerFooterView.comlikeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        headerFooterView.delegate = self
        
        if headerFooterView.comPost0ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapicon(_ :)))
            headerFooterView.comPost0ImageView.addGestureRecognizer(tapGesture)
            headerFooterView.comPost0ImageView.isUserInteractionEnabled = true
        }
        
        if headerFooterView.comPost1ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap1icon(_ :)))
            headerFooterView.comPost1ImageView.addGestureRecognizer(tapGesture)
            headerFooterView.comPost1ImageView.isUserInteractionEnabled = true
        }
        
        if headerFooterView.comPost2ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap2icon(_ :)))
            headerFooterView.comPost2ImageView.addGestureRecognizer(tapGesture)
            headerFooterView.comPost2ImageView.isUserInteractionEnabled = true
        }
        
        if headerFooterView.comPost3ImageView.gestureRecognizers?.count == nil { //重複登録チェック(※)
            //gestureを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap3icon(_ :)))
            headerFooterView.comPost3ImageView.addGestureRecognizer(tapGesture)
            headerFooterView.comPost3ImageView.isUserInteractionEnabled = true
        }
        
        }
        
        return headerFooterView
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white
    }
    
    @objc func addBarButtonTapped(_ sender: UIBarButtonItem) {
        //        let commentPostViewController: CommentPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentPost") as! CommentPostViewController
        //        self.navigationController?.pushViewController(commentPostViewController, animated: true)
        //        commentPostViewController.id = id
        //        commentPostViewController.documentID = documentID
        print("【+】ボタンが押された!")
    }
    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.commentTableView)
        let indexPath = commentTableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = PostData(document: document!)
        
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
        let tappedLocation = gestureRecognizer.location(in: commentTableView)
        let tappedIndexPath = commentTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = PostData(document: document!)

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(0)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected0Img = imageRef
        
        present(zoomInViewController, animated: true)
    }
    
    @objc func tap1icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: commentTableView)
        let tappedIndexPath = commentTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = PostData(document: document!)

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(1)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected1Img = imageRef
        
        present(zoomInViewController, animated: true)
        
    }
    
    @objc func tap2icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: commentTableView)
        let tappedIndexPath = commentTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = PostData(document: document!)

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(2)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected2Img = imageRef
        
        present(zoomInViewController, animated: true)
        
    }
    
    @objc func tap3icon(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = gestureRecognizer.location(in: commentTableView)
        let tappedIndexPath = commentTableView.indexPathForRow(at: tappedLocation)
        let tappedRow = tappedIndexPath?.row
        // 配列からタップされたインデックスのデータを取り出す
        let postData = PostData(document: document!)

        let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(3)" + ".jpg")
        
        let zoomInViewController = self.storyboard?.instantiateViewController(withIdentifier: "ZoomInViewController") as! ZoomInViewController
        
    // 遷移先のZoomInViewControllerで宣言しているselectedImgに値を代入して渡す
        zoomInViewController.selected3Img = imageRef
        
        present(zoomInViewController, animated: true)
        
    }
    
    func popViewController() {
      self.navigationController?.popViewController(animated: true)
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




extension CommentViewController : ChatInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
        print("メッセージ追加")
        
    }
    
    private func addMessageToFirestore(text: String) {
        print("ドキュメント\(id)")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            guard let commentDocument = snapshot?.data() else {return}
            let name = commentDocument["username"] as! String
            let profileImageUrl = commentDocument["profileImageUrl"] as! String
            
            
            self.chatInputAccessoryView.removeText()
            
            let docData = [
                "uid": uid,
                "name": name,
                "date": Timestamp(),
                "comment": text,
                "profileImageUrl": profileImageUrl,
            ] as [String : Any]
            
            Firestore.firestore().collection(Const.PostPath).document(self.id).collection("comments").document().setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                    return
                }
                Firestore.firestore().collection(Const.PostPath).document(self.id).updateData(["commentCount": self.commentArray.count]) { (error) in
                    if let error = error {
                        print("メッセージ情報の保存に失敗しました。\(error)")
                        return
                    }
                }
                print("コメントの保存に成功しました。")
                
            }
            
        }
        
    }
}

