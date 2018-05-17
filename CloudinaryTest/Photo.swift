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
        
        // The name must not be empty
        guard !url.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.url = url
        self.type = type

    }
}
