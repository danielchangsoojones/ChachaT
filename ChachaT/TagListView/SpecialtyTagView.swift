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
    //when the specialtyTagView is initialized, the properties have not been set yet. So, we need to override all these variables when set.
   //The specialtyTagView thinks its intrinsicContentSize is based upon the defualt paddingY, intsead of the manually set PaddingY, so, we say that when the paddintY is set, we want to add the annotationView, so then the annotationView height will be the same as the specialtyTagView's manually set PaddingY.
    @IBInspectable override public var paddingY: CGFloat {
        didSet {
            updateOrCreateAnnotationView(annotationView)
        }
    }
    
    //Purpose: the intrinsicContentSize.height is dependent upon the textFont and the paddingY, so we don't know which will be set first. So, to protect against someone not setting PaddingY or textFont before the other. We just have the annotationView update or create depending on if the annotationView has already been created. That way, it doesn't matter which characteristic is set first. This is safe programming.
    override var textFont: UIFont {
        didSet {
            updateOrCreateAnnotationView(annotationView)
        }
    }
    
    public override var cornerRadius: CGFloat {
        didSet {
            fakeBorder.layer.cornerRadius = cornerRadius
        }
    }
    
    public override var borderWidth: CGFloat {
        didSet {
            //get rid of the actual border, so we can show the fake border
            //The fake border doesn't overlap other views, it goes beneath
            fakeBorder.layer.borderWidth = self.borderWidth
            super.borderWidth = 0
        }
    }
    
    public override var borderColor: UIColor? {
        didSet {
            fakeBorder.layer.borderColor = borderColor?.CGColor
        }
    }

    public override var paddingX: CGFloat {
        didSet {
            let annotationViewDiameter = intrinsicContentSize().height
            titleEdgeInsets.left = paddingX + annotationViewDiameter
        }
    }
    
    var specialtyTagTitle : SpecialtyTagTitles
    var specialtyCategoryTitle : SpecialtyCategoryTitles
    
    var annotationView: AnnotationView?
    var fakeBorder: UIView!
    
    init(specialtyTagTitle: SpecialtyTagTitles, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        self.specialtyTagTitle = specialtyTagTitle
        self.specialtyCategoryTitle = specialtyCategoryTitle
        //TODO: should keep the view's only job to display things, not logic
        if specialtyTagTitle.toString != "None" {
            //specialtyTagTitle has been set to something real
            super.init(title: specialtyTagTitle.toString)
        } else {
            //tag title equals none, so make the title something like "Race" or "Hair Color"
            super.init(title: specialtyCategoryTitle.rawValue)
        }
        createFakeBorder()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Purpose: when I was using the real tag border, it was going above the corner annotation because the border is drawn after all subviews are added.
    //So, in the borderWidth didSet method above, I make the borderWidth = 0 getting rid of the actual border.
    //So, then I create this border view, that looks like all the other borders, but is actually its own view, and this fake border does not cover the annotationView.
    func createFakeBorder() {
        fakeBorder = UIView(frame: self.frame)
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        fakeBorder.userInteractionEnabled = false
        self.addSubview(fakeBorder)
        fakeBorder.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addAnnotationSubview() {
        let annotationView = AnnotationView(diameter: self.intrinsicContentSize().height, color: TagViewProperties.borderColor, imageName: ImageNames.DownArrow)
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        annotationView.userInteractionEnabled = false
        self.addSubview(annotationView)
        annotationView.snp_makeConstraints { (make) in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
    
    //Purpose: the characteristics of the tagView are not created on initilization. So, we need to update or create the annotationView, depending on if it was already created or not.
    func updateOrCreateAnnotationView(annotationView: AnnotationView?) {
        let annotationViewDiameter = self.intrinsicContentSize().height
        if let annotationView = annotationView {
            //theAnnotationView has been made already, but not with the updated characteristics, so we must remove the annotationView and remake it.
            annotationView.updateDiameter(annotationViewDiameter)
        } else {
            //the annotationView has not been created yet or has been removed from superview, and we must re-add it.
            addAnnotationSubview()
        }
        //TODO: I have no fucking idea why the annotationViewDiameter works to make the tags look okay. It should be annotationViewDiameter + paddingX. But, for some reason, that overpads it. I can't figure it out, but somehow the annotationViewDiameter is bigger than the actual annoationView.
        titleEdgeInsets.left = 20
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
    
    public override func intrinsicContentSize() -> CGSize {
        let height = super.intrinsicContentSize().height //height is still calculated like a normal tagView
        let annotationViewDiameter = height
        let width = super.intrinsicContentSize().width + annotationViewDiameter
        return CGSize(width: width, height: height)
    }
    
}
