//
//  SpecialtyTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SpecialtyTagView: TagView {
    
    var tagTitle : String
    var specialtyTagTitle : String
    
    init(tagTitle: String, specialtyTagTitle: String) {
        self.tagTitle = tagTitle
        self.specialtyTagTitle = specialtyTagTitle
        super.init(frame: CGRectZero)
        addCornerAnnotationSubview()
        setTitle(tagTitle, forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func addCornerAnnotationSubview() {
        let cornerAnnotationView = CornerAnnotationView()
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        cornerAnnotationView.userInteractionEnabled = false
        self.addSubview(cornerAnnotationView)
        cornerAnnotationView.snp_makeConstraints { (make) in
            make.leading.equalTo(self).offset(-5)
            make.top.equalTo(self).offset(-5)
            make.width.height.equalTo(20.0)
        }
    }
    
    //need to override becuase when I set the button title, it was not setting the tagTitle variable in this class
    //hence, when we would say layoutSubviews was not changing to the new size because it still thought it was the old tagTitle
    override func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle(title, forState: .Normal)
        if let title = title {
            tagTitle = title
        }
    }
    
}
