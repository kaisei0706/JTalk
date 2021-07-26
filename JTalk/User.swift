//
//  User.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/06.
//

import Foundation
import Firebase
class User {
    
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    let year : String
    let profile : String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.year = dic["year"] as? String ?? ""
        self.profile = dic["profile"] as? String ?? ""
    }
    
    
}
