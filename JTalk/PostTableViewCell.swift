//
//  PostTableViewCell.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/06.
//

import UIKit
import FirebaseUI
import Firebase
import Nuke

class PostTableViewCell: UITableViewCell {
    
    
    //         Firestoreのリスナー
    var listener: ListenerRegistration!
    var delegate: UIViewController?
    private var isOwner: Bool = false
    var id = ""
    var strCounter: Int = 0
    
    
    @IBOutlet weak var post0ImageView: UIImageView!
    @IBOutlet weak var post1ImageView: UIImageView!
    @IBOutlet weak var post2ImageView: UIImageView!
    @IBOutlet weak var post3ImageView: UIImageView!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userTextLabel: UILabel!
    @IBOutlet weak var userPostView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBAction func dispAlert(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "アラート表示", message: "保存してもいいですか？", preferredStyle:  UIAlertController.Style.actionSheet)
        
        let defaultAction_1: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("削除")
            
            let numbers = [0,1,2,3]
            let imageRef = Storage.storage().reference().child(Const.PostImagePath)
            
            for n in numbers {
                let desertRef = imageRef.child((self.id) + "\(n)" + ".jpg")
                desertRef.delete { error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        print("\((self.id) + "\(n)" + ".jpg")削除成功")
                    }
                }
            
                
                
            }
            let postsRef = Firestore.firestore().collection(Const.PostPath).document(self.id)
            postsRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    
                }
            }
        })
        
        let defaultAction_2: UIAlertAction = UIAlertAction(title: "報告する", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("報告する")
        })
        
        // Cancelボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        
        
        
        
        if isOwner == true {
            alert.addAction(defaultAction_1)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(defaultAction_2)
            alert.addAction(cancelAction)
        }
        
        
        // ④ Alertを表示
        delegate!.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        userPostView.layer.borderColor = UIColor.gray.cgColor
        userPostView.layer.borderWidth = 0.5
        self.userPostView.layer.cornerRadius = 5
        userImageView.layer.cornerRadius = 25
        // Configure the view for the selected state
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData, isOwner: Bool) {
        
        id = postData.id
        // 画像の表示
        post0ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        post1ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        print("枚数\(postData.imageCounts)")
        
        if postData.imageCounts == 0 {
            post0ImageView.isHidden = true
            post1ImageView.isHidden = true
            post2ImageView.isHidden = true
            post3ImageView.isHidden = true
        }
        
        if postData.imageCounts == 1 {
            post1ImageView.isHidden = true
            post2ImageView.isHidden = true
            post3ImageView.isHidden = true
            
        }
        
        if postData.imageCounts == 2 {
            post2ImageView.isHidden = true
            post3ImageView.isHidden = true
        }
        
        if postData.imageCounts == 3 {
            post3ImageView.isHidden = true
        }
        
        
        var images: [StorageReference] = []
        strCounter = 0
        while strCounter < 4 {
            let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(strCounter)" + ".jpg")
            images.append(imageRef)
            print("配列\(images)")
            
            if strCounter == 0 {
                print("レフ\(imageRef)")
                post0ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 1 {
                print("レフ1\(imageRef)")
                post1ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 2 {
                print("レフ2\(imageRef)")
                post2ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 3 {
                print("レフ3\(imageRef)")
                post3ImageView.sd_setImage(with: imageRef)
            }
            
            
            strCounter += 1
        }
        
        
        
        self.userNameLabel.text = "\(postData.name!)"
        // 投稿の表示
        self.userTextLabel.text = "\(postData.text!)"
        
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
            
            if let url = URL(string: postData.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            
        }
        if postData.commentCount == nil {
            self.countLabel.text = "0"
        } else {
            self.countLabel.text = "\(postData.commentCount!)"
        }
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        self.isOwner = isOwner
        
        
    }
    
}
