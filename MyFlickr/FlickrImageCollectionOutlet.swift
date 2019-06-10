//
//  FlickrImageCollectionOutlet.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit

class FlickrImageCollectionOutlet : NSObject {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var paginationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var paginationIndicatorView: UIView!
    @IBOutlet weak var paginationIndicatorBottom: NSLayoutConstraint!
    
}
