//
//  PhotoViewController.swift
//  CloudinaryTest
//
//  Created by Olya Tilichenko on 21.05.2018.
//  Copyright © 2018 Olga. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var stringUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: stringUrl!)
        imageView.kf.setImage(with: url)
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.addTarget(self, action: #selector(self.back))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
