//
//  PostData.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/06.
//

import Foundation
import Firebase

class PostData: NSObject {
    var id: String
    var teamName : String?
    var uid : String?
    var name: String?
    var profileImageUrl: String?
    var date: Date?
    var text: String?
    var comment: String?
    var commentCount : Int?
    var imageCounts : Int?
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()!
        
        self.teamName = postDic["teamName"] as? String
        
        self.uid = postDic["uid"] as? String
        
        self.name = postDic["name"] as? String
        
        self.profileImageUrl = postDic["profileImageUrl"] as? String ?? ""
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        self.text = postDic["text"] as? String
        
        self.comment = postDic["comment"] as? String
        
        self.commentCount = postDic["commentCount"] as? Int
        
        self.imageCounts = postDic["imageCounts"] as? Int
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
        
        
    }
    
    
}
