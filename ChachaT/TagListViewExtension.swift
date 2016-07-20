//
//  TagListViewExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/7/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

//TODO: I think a subclass makes more sense to do set the attributes of the tag and have it useable in the storyboard, but
//I could not figure out how to subclass the taglistView because it has IBInspectable
//attributes in the storyboar
extension TagListView {
    func addChoicesTagListViewAttributes() {
        self.tagBackgroundColor = ChachaTeal.colorWithAlphaComponent(0.66)
        self.cornerRadius = 9
        self.paddingY = 6
        self.textColor = PeriwinkleGray
        self.alignment = .Center
    }
    
    func addChosenTagListViewAttributes() {
        addChoicesTagListViewAttributes()
        self.enableRemoveButton = true
    }
}
