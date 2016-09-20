//
//  DropDownTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class DropDownTagView: SpecialtyTagView {
    var specialtyCategoryTitle : String = ""
    
    init(tagTitle: String, specialtyCategoryTitle: String) {
        super.init(tagTitle: tagTitle, tagAttribute: .DropDownMenu)
        self.specialtyCategoryTitle = specialtyCategoryTitle
    }
    
    func makePrivate() {
        annotationView.updateImage("SettingsGear")
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
