//
//  Posts.swift
//  PracticaBoot4
//
//  Created by MIGUEL JARDÓN PEINADO on 5/10/17.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation
import Firebase


struct Posts {
    
    let title       : String
    let description : String
    let isVisible   : Bool
    let photo       : String
    var postRef     : DatabaseReference?
    
    init(title: String, description: String, isVisible: Bool, photo: String) {
        (self.title, self.description) = (title, description)
        self.isVisible = isVisible
        self.photo = photo
        self.postRef = nil
    }
    
    init?(snapShot: DataSnapshot) {
        guard let item = snapShot.value as? [String: Any] else { return nil }
        
        self.title = item["title"] as! String
        self.description = item["description"] as! String
        self.isVisible = item["isVisible"] as! Bool
        self.photo = item["photo"] as! String
        self.postRef = snapShot.ref
    }
}
