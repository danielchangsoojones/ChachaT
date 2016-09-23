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

open class SpecialtyTagView: TagView {
    struct AnnotationImages {
        static let dropDownMenu = ImageNames.DownArrow
        static let isPrivate = "SettingsGear"
    }
    
    
    //when the specialtyTagView is initialized, the properties have not been set yet. So, we need to override all these variables when set.
   //The specialtyTagView thinks its intrinsicContentSize is based upon the defualt paddingY, intsead of the manually set PaddingY, so, we say that when the paddintY is set, we want to add the annotationView, so then the annotationView height will be the same as the specialtyTagView's manually set PaddingY.
    @IBInspectable override open var paddingY: CGFloat {
        didSet {
            updateAnnotationView()
        }
    }
    
    //Purpose: the intrinsicContentSize.height is dependent upon the textFont and the paddingY, so we don't know which will be set first. So, to protect against someone not setting PaddingY or textFont before the other. We just have the annotationView update or create depending on if the annotationView has already been created. That way, it doesn't matter which characteristic is set first. This is safe programming.
    override var textFont: UIFont {
        didSet {
            updateAnnotationView()
        }
    }
    
    open override var cornerRadius: CGFloat {
        didSet {
            fakeBorder.layer.cornerRadius = cornerRadius
        }
    }
    
    open override var borderWidth: CGFloat {
        didSet {
            //get rid of the actual border, so we can show the fake border
            //The fake border doesn't overlap other views, it goes beneath
            fakeBorder.layer.borderWidth = self.borderWidth
            super.borderWidth = 0
        }
    }
    
    open override var borderColor: UIColor? {
        didSet {
            fakeBorder.layer.borderColor = borderColor?.cgColor
        }
    }

    open override var paddingX: CGFloat {
        didSet {
            updateAnnotationView()
        }
    }
    
    var tagAttribute : TagAttributes = .generic
    
    var annotationView: AnnotationView!
    var fakeBorder: UIView!
    
    init(tagTitle: String, tagAttribute: TagAttributes) {
        self.tagAttribute = tagAttribute
        super.init(title: tagTitle)
        addAnnotationSubview()
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
        fakeBorder.isUserInteractionEnabled = false
        self.addSubview(fakeBorder)
        fakeBorder.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addAnnotationSubview() {
        annotationView = AnnotationView(diameter: self.intrinsicContentSize().height, color: TagViewProperties.borderColor, imageName: setAnnotationImage(tagAttribute))
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        annotationView.isUserInteractionEnabled = false
        self.addSubview(annotationView)
        annotationView.snp_makeConstraints { (make) in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
    
    func setAnnotationImage(_ tagAttribute: TagAttributes) -> String {
        switch tagAttribute {
        case .dropDownMenu:
            return AnnotationImages.dropDownMenu
        default:
            return ""
        }
    }
    
    func updateAnnotationView() {
        let annotationViewDiameter = self.intrinsicContentSize().height
        annotationView.updateDiameter(annotationViewDiameter)
        //TODO: I have no fucking idea why the annotationViewDiameter works to make the tags look okay. It should be annotationViewDiameter + paddingX. But, for some reason, that overpads it. I can't figure it out, but somehow just setting annotationViewDiameter is bigger than the actual annoationView.
        titleEdgeInsets.left = annotationViewDiameter
    }
    
    open override var intrinsicContentSize : CGSize {
        let height = super.intrinsicContentSize().height //height is still calculated like a normal tagView
        let annotationViewDiameter = height
        let width = super.intrinsicContentSize().width + annotationViewDiameter
        return CGSize(width: width, height: height)
    }
    
}
