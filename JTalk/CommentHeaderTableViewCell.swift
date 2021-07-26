//
//  CommentHeaderTableViewCell.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/26.
//

import UIKit
import Firebase
import Nuke

class CommentHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comMainImageView: UIImageView!
    @IBOutlet weak var comMainUserNameLabel: UILabel!
    @IBOutlet weak var comMainuserTextLabel: UILabel!
    @IBOutlet weak var comMainDateLabel: UILabel!
    
    var date: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setPPostData(_ document: DocumentSnapshot?) {
        
        comMainUserNameLabel.text = document?.get("name") as? String
        comMainuserTextLabel.text = document?.get("text") as? String
        self.comMainDateLabel.text = ""

        let timestamp = document?.get("date") as? Timestamp
        self.date = timestamp?.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date!)
        self.comMainDateLabel.text = dateString
        
        if let url = URL(string: document?.get("profileImageUrl") as? String ?? "" ) {
            Nuke.loadImage(with: url, into: comMainImageView)
        }
        
    }
}
