//
//  FlickrImageDetailViewController.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit

class FlickrImageDetailViewController : UIViewController {
    
    @IBOutlet weak var fullImageView: UIImageView!
    var imageSelected = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        fullImageView.image = imageSelected
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
