//
//  CommentHeaderFooterView.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/04/07.
//

import UIKit
import FirebaseUI
import Firebase
import Nuke

protocol CommentHeaderFooterViewDelegate: class {
    func popViewController()
}

class CommentHeaderFooterView: UITableViewHeaderFooterView {
    
    var delegate2: CommentHeaderFooterViewDelegate?
    var listener: ListenerRegistration!
    var delegate: UIViewController?
    private var isOwner: Bool = false
    var id = ""
    var date: Date?
    var isLiked: Bool = false
    var likes:[String] = []
    var strCounter: Int = 0
    var listener2: ListenerRegistration!
    
    
    @IBOutlet weak var comMainView: UIView!
    @IBOutlet weak var comMainImageView: UIImageView!
    @IBOutlet weak var comMainUserNameLabel: UILabel!
    @IBOutlet weak var comMainTextLabel: UILabel!
    @IBOutlet weak var comMainDateLabel: UILabel!
    @IBOutlet weak var comCountLabel: UILabel!
    @IBOutlet weak var comlikeButton: UIButton!
    @IBOutlet weak var comlikeLabel: UILabel!
    @IBOutlet weak var comPost0ImageView: UIImageView!
    @IBOutlet weak var comPost1ImageView: UIImageView!
    @IBOutlet weak var comPost2ImageView: UIImageView!
    @IBOutlet weak var comPost3ImageView: UIImageView!
    
    @IBAction func dispAlert(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "アラート表示", message: "保存してもいいですか？", preferredStyle:  UIAlertController.Style.actionSheet)
        
        let defaultAction_1: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("削除")
            let postsRef = Firestore.firestore().collection(Const.PostPath).document(self.id)
            postsRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.delegate2?.popViewController()
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
    
    
    func setup(_ postData: PostData, isOwner: Bool) {
        
        comMainView.layer.borderColor = UIColor.gray.cgColor
        comMainView.layer.borderWidth = 0.5
        self.comMainView.layer.cornerRadius = 5
        comMainImageView.layer.cornerRadius = 25
        
        id = postData.id
        
        let userRef = Firestore.firestore().collection(Const.UserPath).document(postData.uid!)
        
        
        listener2 = userRef.addSnapshotListener(){ (document, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            self.comMainUserNameLabel.text =  document?.get("username") as? String
            
            let imageFileUrl = document?.get("profileImageUrl") as! String
            self.showImage(imageView: self.comMainImageView, url: "\(imageFileUrl)")
            
        }
        // 画像の表示
        comPost0ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        comPost1ImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        print("枚数\(postData.imageCounts)")
        
        if postData.imageCounts == 0 {
            comPost0ImageView.isHidden = true
            comPost1ImageView.isHidden = true
            comPost2ImageView.isHidden = true
            comPost3ImageView.isHidden = true
        }

        if postData.imageCounts == 1 {
            comPost1ImageView.isHidden = true
            comPost2ImageView.isHidden = true
            comPost3ImageView.isHidden = true
            
        }

        if postData.imageCounts == 2 {
            comPost2ImageView.isHidden = true
            comPost3ImageView.isHidden = true
        }

        if postData.imageCounts == 3 {
            comPost3ImageView.isHidden = true
        }

        
        var images: [StorageReference] = []
        strCounter = 0
        while strCounter < 4 {
            let imageRef = Storage.storage().reference().child(Const.PostImagePath).child((postData.id) + "\(strCounter)" + ".jpg")
            images.append(imageRef)
            print("配列\(images)")
            
            if strCounter == 0 {
                print("レフ\(imageRef)")
                comPost0ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 1 {
                print("レフ2\(imageRef)")
                comPost1ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 2 {
                print("レフ2\(imageRef)")
                comPost2ImageView.sd_setImage(with: imageRef)
            }
            else if strCounter == 3 {
                print("レフ2\(imageRef)")
                comPost3ImageView.sd_setImage(with: imageRef)
            }
            
            
            strCounter += 1
        }
        
        // 投稿の表示
        self.comMainTextLabel.text = "\(postData.text!)"
        
        // 日時の表示
        self.comMainDateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.comMainDateLabel.text = dateString
            
            if let url = URL(string: postData.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: comMainImageView)
            }
            
            
        }
        if postData.commentCount == nil {
            self.comCountLabel.text = "0"
        } else {
            self.comCountLabel.text = "\(postData.commentCount!)"
        }
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        comlikeLabel.text = "\(likeNumber)"
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.comlikeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.comlikeButton.setImage(buttonImage, for: .normal)
        }
        
        self.isOwner = isOwner
        
        
    }
    
    private func showImage(imageView: UIImageView, url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            imageView.image = image
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
    }
    
    
    
/*
 // Only override draw() if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 override func draw(_ rect: CGRect) {
 // Drawing code
 }
 */

}
