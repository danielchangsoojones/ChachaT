//
//  ChachaChosenTagListView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class ChachaChosenTagListView : ChachaChoicesTagListView {
    
    //for some reason, when using IBinspectables, I have to have this init even though only the coder init gets called
    //keep this init despite it seeming to not do anything.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //get rid of the border
        borderColor = nil
        borderWidth = 0
        tagBackgroundColor = TagViewProperties.borderColor
        let tagInsidesColor = TagViewProperties.tagInsidesColor
        enableRemoveButton = true
        removeIconLineColor = tagInsidesColor
        textColor = tagInsidesColor
    }
    
}
