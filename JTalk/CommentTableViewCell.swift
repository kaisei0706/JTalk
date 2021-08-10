//
//  CommentTableViewCell.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/31.
//

import UIKit
import Firebase
import Nuke

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comImageView: UIImageView!
    @IBOutlet weak var comNameLabel: UILabel!
    @IBOutlet weak var comTextLabel: UILabel!
    @IBOutlet weak var comDateLabel: UILabel!
    
    var date: Date?
    var listener2: ListenerRegistration!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        comImageView.layer.cornerRadius = 25
    }
    
    func setPostData(_ commentData: CommentData) {
        
        let userRef = Firestore.firestore().collection(Const.UserPath).document(commentData.uid!)
        listener2 = userRef.addSnapshotListener(){ (document, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            
            self.comNameLabel.text =  document?.get("username") as? String
            let imageFileUrl = document?.get("profileImageUrl") as! String
            self.showImage(imageView: self.comImageView, url: "\(imageFileUrl)")
            
        }
        
        print("コメントデータ読み込む")
        comTextLabel.text = "\(commentData.comment!)"
        
        // 日時の表示
        let timestamp = commentData.date
        self.date = timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date!)
        self.comDateLabel.text = dateString
        
        if let url = URL(string: commentData.profileImageUrl ?? "" ) {
            Nuke.loadImage(with: url, into: comImageView)
        }
        
        
        
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
    
}
