//
//  Photo.swift
//  PhotoAlbum
//

import UIKit
import os.log


class Photo: NSObject {
    
    //MARK: Properties
    
    var url: String
    var type: String
    
    //MARK: Initialization
    
    init?(url: String, type: String) {
        
        guard !url.isEmpty else {
            return nil
        }
        
        self.url = url
        self.type = type

    }
}
