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
        
        print("コメントデータ読み込む")
        comNameLabel.text = "\(commentData.name!)"
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
    
}
