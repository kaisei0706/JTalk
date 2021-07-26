//
//  ZoomInViewController.swift
//  JTalk
//
//  Created by 岩田海靖 on 2021/06/17.
//

import UIKit
import Firebase

class ZoomInViewController: UIViewController {
    
    var selected0Img: StorageReference!
    var selected1Img: StorageReference!
    var selected2Img: StorageReference!
    var selected3Img: StorageReference!
    
    @IBOutlet weak var zoomInImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        if selected0Img != nil {
            zoomInImageView.sd_setImage(with: selected0Img)
        } else if selected1Img != nil {
            zoomInImageView.sd_setImage(with: selected1Img)
        } else if selected2Img != nil {
            zoomInImageView.sd_setImage(with: selected2Img)
        } else if selected3Img != nil {
            zoomInImageView.sd_setImage(with: selected3Img)
        }
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissView))
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
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
