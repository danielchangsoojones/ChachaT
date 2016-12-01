//
//  MyMenuItem.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class MyMenuItem: UIMenuItem {
    var correspondingObject: Any?
    
    init(title: String, action: Selector, correspondingObject: Any? = nil) {
        super.init(title: title, action: action)
        self.correspondingObject = correspondingObject
    }
}
