//
//  MenuViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/03/19.
//

import UIKit
import Firebase


class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 投稿データを格納する配列
    var teamArray: [Team] = []
    let team1: [String] = []
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var jListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jListTableView.delegate = self
        jListTableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // listener未登録なら、登録してスナップショットを受信する
        Firestore.firestore().collection(Const.TeamPath).order(by: "number").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("team名の取得に失敗しました。\(err)")
                return
            }
            
            self.teamArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let teamData = Team(document: document)
                return teamData
                
            }
            
            self.jListTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let team = teamArray[indexPath.row]
        cell.textLabel?.text = team.id
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let homeViewController: HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
        let team = teamArray[indexPath.row]
        _ = self.jListTableView.indexPathForSelectedRow
        homeViewController.documentID = team.id
        homeViewController.red = team.red
        homeViewController.green = team.green
        homeViewController.blue = team.blue
        print("チームID\(homeViewController.documentID)")
        self.navigationController?.pushViewController(homeViewController, animated: true)
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
