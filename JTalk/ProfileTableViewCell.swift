//
//  ProfileTableViewCell.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/05/19.
//

import UIKit
import FirebaseUI
import Firebase
import Nuke

class ProfileTableViewCell: UITableViewCell {
    
    var delegate: UIViewController?

    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileTextLabel: UILabel!
    @IBOutlet weak var pprofilePostView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profiledateLabel: UILabel!
    @IBOutlet weak var profilecountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        pprofilePostView.layer.borderColor = UIColor.gray.cgColor
        pprofilePostView.layer.borderWidth = 0.5
        self.pprofilePostView.layer.cornerRadius = 5
        profileImageView.layer.cornerRadius = 25

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData) {
        
        self.profileNameLabel.text = "\(postData.name!)"
        // 投稿の表示
        self.profileTextLabel.text = "\(postData.text!)"
        
        // 日時の表示
        self.profiledateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.profiledateLabel.text = dateString
            
            if let url = URL(string: postData.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: profileImageView)
            }
            
            
        }
        if postData.commentCount == nil {
            self.profilecountLabel.text = "0"
        } else {
            self.profilecountLabel.text = "\(postData.commentCount!)"
        }
        
    }
}
