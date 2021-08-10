//
//  PostViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/03.
//

import UIKit
import Firebase
import Nuke
import PhotosUI


import SVProgressHUD

class PostViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var post1ImageView: UIImageView!
    @IBOutlet weak var post2ImageView: UIImageView!
    @IBOutlet weak var post3ImageView: UIImageView!
    
    var counter:Int = 0
    var ItemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    var image: UIImage!
    var images = [UIImage]()
    var strCounter: Int = 0
    var imagecounter = 0
    
    
    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 4
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func displayNextImage(){
        if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = postImageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in DispatchQueue.main.async {
                guard let self = self, let image = image as? UIImage, self.postImageView.image == previousImage else {return}
                self.postImageView.image = image
            }}
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayNextImage()
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // Use UIImage
                        print("Selected image: \(image)")
                        if ( self.counter == 0 ) {
                            self.postImageView.image = image
                            self.images.append(image)
                        }
                        else if ( self.counter == 1 ) {
                            self.post1ImageView.image = image
                            self.images.append(image)
                        }
                        
                        else if ( self.counter == 2 ) {
                            self.post2ImageView.image = image
                            self.images.append(image)
                        }
                        else if ( self.counter == 3 ) {
                            self.post3ImageView.image = image
                            self.images.append(image)
                        }
                        
                        self.counter += 1
                        
                    }
                }
            })
        }
    }
    
    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    private var users = [User]()
    
    var documentID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postUserImageView.layer.cornerRadius = 32.5
        postTextView.layer.borderColor = UIColor.lightGray.cgColor
        postTextView.layer.borderWidth = 1.0
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        
        Firestore.firestore().collection("users").document(uid).getDocument { [self] ( snapshot, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.postNameLabel.text = user.username
            
            if let url = URL(string: user.profileImageUrl ) {
                Nuke.loadImage(with: url, into: postUserImageView)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func postDoneButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        var imageCounts = images.count
        if imageCounts == 0 {
            Firestore.firestore().collection("users").document(uid).getDocument { ( snapshots, err) in
                if let err = err {
                    print("user情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let snapshot = snapshots, let dic = snapshot.data() else { return }
                
                let user = User(dic: dic)
                let profileImageUrl = user.profileImageUrl
                
                let postDic = [
                    "teamName": self.documentID,
                    "uid": uid,         
                    "date": FieldValue.serverTimestamp(),
                    "text": self.postTextView.text!,
                    "commentCount": 0,
                    "imageCounts": 0,
                ] as [String : Any]
                postRef.setData(postDic)
                SVProgressHUD.showSuccess(withStatus: "投稿しました")
                SVProgressHUD.dismiss(withDelay: 1)
                self.navigationController?.popViewController(animated: true)
                
            }
        } else {
            
            
            for image in images {
                let imageData = image.jpegData(compressionQuality: 0.75)
                // 画像と投稿データの保存場所を定義する
                let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postRef.documentID) + "\(strCounter)" + ".jpg")
                // HUDで投稿処理中の表示を開始
                SVProgressHUD.show()
                // Storageに画像をアップロードする
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                imageRef.putData(imageData!, metadata: metadata) { [self] (metadata, error) in
                    imagecounter += 1
                    if error != nil {
                        // 画像のアップロード失敗
                        print(error!)
                        SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                        // 投稿処理をキャンセルし、先頭画面に戻る
                        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    print("イメージカウント\(self.images.count)")
                    print("イメージカウント\(imagecounter)")
                    
                    if self.images.count  == imagecounter {
                        Firestore.firestore().collection("users").document(uid).getDocument { ( snapshots, err) in
                            if let err = err {
                                print("user情報の取得に失敗しました。\(err)")
                                return
                            }
                            
                            guard let snapshot = snapshots, let dic = snapshot.data() else { return }
                            
                            let user = User(dic: dic)
                            let profileImageUrl = user.profileImageUrl
                            
                            let postDic = [
                                "teamName": self.documentID,
                                "uid": uid,
                                "name": self.postNameLabel.text!,
                                "profileImageUrl" : profileImageUrl,
                                "date": FieldValue.serverTimestamp(),
                                "text": self.postTextView.text!,
                                "commentCount": 0,
                                "imageCounts": imageCounts,
                            ] as [String : Any]
                            postRef.setData(postDic)
                            SVProgressHUD.showSuccess(withStatus: "投稿しました")
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }
                    
                    
                }
                
                self.strCounter += 1
                
            }
            
        }
    }
}
