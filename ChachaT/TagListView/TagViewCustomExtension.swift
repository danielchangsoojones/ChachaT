//
//  TagViewCustomExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension TagView {
    func isFromSpecialtyCategory() -> SpecialtyCategoryTitles? {
        if let currentTitle = self.currentTitle {
            if let specialtyTagTitle = SpecialtyTagTitles.stringRawValue(currentTitle) {
                //the tagView is part of a specialtyCategory (like Democrat, Blonde, ect.)
                if let specialtyCategoryTitle = specialtyTagTitle.associatedSpecialtyCategoryTitle {
                    return specialtyCategoryTitle
                }
            }
        }
        //the tag is just a random generic tag, with no specialty tag
        return nil
    }
    
    //Purpose: the search bar text field needs to calculate height to the same height as the tagViews. Like in 8tracks
    static func getTagViewHeight(paddingY: CGFloat) -> CGFloat {
        let textFont : UIFont = UIFont.systemFontOfSize(12)
        return textFont.pointSize + paddingY * 2 //this is the tagView height
    }
}