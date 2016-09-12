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

public class SpecialtyTagView: TagView {
    
    var specialtyTagTitle : SpecialtyTagTitles
    var specialtyCategoryTitle : SpecialtyCategoryTitles
    
    init(specialtyTagTitle: SpecialtyTagTitles, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        self.specialtyTagTitle = specialtyTagTitle
        self.specialtyCategoryTitle = specialtyCategoryTitle
        super.init(frame: CGRectZero)
        createFakeBorder(TagViewProperties.borderColor, borderWidth: TagViewProperties.borderWidth, cornerRadius: TagViewProperties.cornerRadius)
        addFrontAnnotationSubview()
        if specialtyTagTitle.toString != "None" {
            //specialtyTagTitle has been set to something real
            setTitle(specialtyTagTitle.toString, forState: .Normal)
        } else {
            //tag title equals none, so make the title something like "Race" or "Hair Color"
            setTitle(specialtyCategoryTitle.rawValue, forState: .Normal)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Purpose: when I was using the real tag border, it was going above the corner annotation because the border is drawn after all subviews are added.
    //So, in the addSpecialtyTagMethod, I had to make the borderWidth = 0 and borderColor = nil, getting rid of actual border
    //I couldn't change the borderWidth/borderColor in this class because, for some reason, they were not initialized yet. 
    //So, then I create this border view, that looks like all the other borders, but is actually its own view, and this fake border does not cover the corner annotation.
    func createFakeBorder(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        let view = UIView(frame: self.frame)
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.CGColor
        view.layer.cornerRadius = cornerRadius
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        view.userInteractionEnabled = false
        self.addSubview(view)
        view.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addFrontAnnotationSubview() {
        let annotationView = AnnotationView()
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        annotationView.userInteractionEnabled = false
        self.addSubview(annotationView)
        annotationView.snp_makeConstraints { (make) in
            make.leading.equalTo(self).offset(-5)
            make.top.equalTo(self).offset(-5)
            make.width.height.equalTo(20.0)
        }
    }
    
    //need to override becuase when I set the button title, it was not setting the tagTitle variable in this class
    //hence, when we would say layoutSubviews was not changing to the new size because it still thought it was the old tagTitle
    override public func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle(title, forState: .Normal)
        if let title = title {
            if let specialtyTagTitle = SpecialtyTagTitles.stringRawValue(title) {
                self.specialtyTagTitle = specialtyTagTitle
            } else if let specialtyCategoryTitle = SpecialtyCategoryTitles(rawValue: title) {
                self.specialtyCategoryTitle = specialtyCategoryTitle
            }
        }
    }
    
}
