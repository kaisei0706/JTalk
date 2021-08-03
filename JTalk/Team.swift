//
//  Team.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/20.
//

import Foundation
import Firebase

class Team: NSObject {
    var id: String
    var name: String?
    var red: CGFloat?
    var green: CGFloat?
    var blue: CGFloat?

    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let teamDic = document.data()
        
        self.name = teamDic["name"] as? String
        
        self.red = teamDic["red"] as? CGFloat
        
        self.green = teamDic["green"] as? CGFloat

        self.blue = teamDic["blue"] as? CGFloat

    }
}
