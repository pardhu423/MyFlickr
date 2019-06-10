//
//  FlickrImageModel.swift
//  MyFlickr
//
//  Created by Pardhu G on 09/06/19.
//  Copyright © 2019 Pardhu G. All rights reserved.
//

import UIKit

enum FlickrImageModelState {
    /* To represent the status of the image download operation in the queue */
    case new, downloaded, failed
}

class FlickrImageModel {
    
    var id: String?
    var title: String?
    var link: URL?
    var farm: Int?
    var server: String?
    var secret: String?
    var image: UIImage?
    var state = FlickrImageModelState.new
    
    init(dataSource: [String: Any]) {
        
        self.title = dataSource["title"] as? String
        self.id = dataSource["id"] as? String
        self.farm = dataSource["farm"] as? Int
        self.server = dataSource["server"] as? String
        self.secret = dataSource["secret"] as? String
        
        self.link = URL(string: "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!).jpg")
        
    }
    
}
