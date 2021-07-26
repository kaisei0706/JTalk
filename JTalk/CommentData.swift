//
//  CommentData.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/04/08.
//

import Foundation
import Firebase

class CommentData: NSObject {
    var id: String
    var uid : String?
    var profileImageUrl: String?
    var name: String?
    var text: String?
    var date: Date?
    var comment: String?
    
//    var likes: [String] = []
//    var isLiked: Bool = false
    
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.profileImageUrl = postDic["profileImageUrl"] as? String ?? ""
        
        self.uid = postDic["uid"] as? String
        
        self.name = postDic["name"] as? String
        
        self.text = postDic["text"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
//        if let likes = postDic["likes"] as? [String] {
//            self.likes = likes
//        }
//        if let myid = Auth.auth().currentUser?.uid {
//            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
//            if self.likes.firstIndex(of: myid) != nil {
//                // myidがあれば、いいねを押していると認識する。
//                self.isLiked = true
//            }
//        }
        
        
        self.comment = postDic["comment"] as? String
        
        
    }
    
    
}
