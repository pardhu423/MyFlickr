//
//  FlickrImageCollectionViewCell.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit

class FlickrImageCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    func configureCellWith(photoData: FlickrImageModel) {
        
        imageName.text = photoData.title ?? "Photo Image"
        
        if let image = photoData.image {
            imageContainer.backgroundColor = UIColor.clear
            imageContainer.image = image
            loader.stopAnimating()
        } else {
            imageContainer.image = UIImage()
            imageContainer.backgroundColor = UIColor.groupTableViewBackground
            loader.startAnimating()
        }
    }
    
    func errorLoading() {
        
        loader.stopAnimating()
        imageContainer.backgroundColor = UIColor.groupTableViewBackground
        imageName.text = "Image failed to load"
    }
    
}
