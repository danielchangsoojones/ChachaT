//
//  CreationTagListView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CreationTagListView: ChachaChoicesTagListView {
    //for some reason, when using IBinspectables, I have to have this init even though only the coder init gets called
    //keep this init despite it seeming to not do anything.
    var creationTagView: CreationTagView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCreationTagView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addCreationTagView() {
        creationTagView = CreationTagView(textFont: textFont, paddingX: paddingX, paddingY: paddingY, borderWidth: borderWidth, cornerRadius: cornerRadius, tagBackgroundColor: tagBackgroundColor)
        _ = self.addTagView(creationTagView)
    }
}
