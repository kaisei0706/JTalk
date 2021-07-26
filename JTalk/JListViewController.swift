//
//  JListViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/18.
//

import UIKit
import Firebase


class JListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var jListTableView: UITableView!
    
    // 投稿データを格納する配列
    var teamArray: [Team] = []
    let team1: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jListTableView.delegate = self
        jListTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        // listener未登録なら、登録してスナップショットを受信する
        Firestore.firestore().collection(Const.PostPath).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("team名の取得に失敗しました。\(err)")
                return
            }
            
            self.teamArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                print("チーム配列: \(self.teamArray)")
                let teamData = Team(document: document)
                return teamData
                
            }
            self.jListTableView.reloadData()
            
            //                print("data: ", data)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team1.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let team = team1[indexPath.row]
        cell.textLabel?.text = team
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        // セルを取得してデータを設定する
        //        let cell = jListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //
        //        performSegue(withIdentifier: "cellSegue",sender: nil)
        //
        //        cell.commentButton.addTarget(self, action:#selector(newcommentButton(_:forEvent:)), for: .touchUpInside)
        
        
    }



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
