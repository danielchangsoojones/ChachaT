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
        static let isPrivate = "LockIcon"
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
    
    var annotationView: AnnotationView?
    var fakeBorder: UIView!
    
    init(tagTitle: String, tagAttribute: TagAttributes) {
        self.tagAttribute = tagAttribute
        super.init(title: tagTitle)
        createAnnotationViewWithImage()
        createFakeBorder()
    }
    
    init(tagTitle: String, innerLabelText: String) {
        self.tagAttribute = .innerText
        super.init(title: tagTitle)
        createAnnotationViewWithInnerText(text: innerLabelText)
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
        fakeBorder.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    //For when we want an image like an arrow or lock to be in the middle of the annotation image
    fileprivate func createAnnotationViewWithImage() {
        annotationView = AnnotationView(diameter: self.intrinsicContentSize.height, color: TagViewProperties.borderColor, imageName: setAnnotationImage(tagAttribute))
        addAnnotationSubview(annotationView: annotationView!)
    }
    
    fileprivate func createAnnotationViewWithInnerText(text: String) {
        //I will have to update padddingX when the paddingX gets set
        annotationView = AnnotationView(diameter: self.intrinsicContentSize.height, color: TagViewProperties.borderColor, innerText: text)
        addAnnotationSubview(annotationView: annotationView!)
    }
    
    fileprivate func addAnnotationSubview(annotationView: AnnotationView) {
        //false user interaction, so users can click on the actual tag, which is underneath this subview. Without this, if you tapped on the tag special area, then nothing would happen.
        annotationView.isUserInteractionEnabled = false
        self.addSubview(annotationView)
        annotationView.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
    
    func setAnnotationImage(_ tagAttribute: TagAttributes) -> String {
        switch tagAttribute {
        case .dropDownMenu:
            return AnnotationImages.dropDownMenu
        case .isPrivate:
            return AnnotationImages.isPrivate
        default:
            return ""
        }
    }
    
    func updateAnnotationView() {
        annotationView?.updateDiameter(self.intrinsicContentSize.height)
        //TODO: For some reason, the titleEdgeInset is a little far left,I have no idea why. So, I take off a little of the padding, so it looks right. The math should just be paddingX + annotationView.intrinsicContentSize, but this doesn't look correct.
        titleEdgeInsets.left = annotationView!.intrinsicContentSize.width + paddingX
    }
    
    open override var intrinsicContentSize : CGSize {
        let height = super.intrinsicContentSize.height //height is still calculated like a normal tagView
        let annotationViewWidth: CGFloat = annotationView?.intrinsicContentSize.width ?? 0
        let width = super.intrinsicContentSize.width + annotationViewWidth
        return CGSize(width: width, height: height)
    }
}

//Extension for annotationViews with inner text
extension SpecialtyTagView {
    func convertToInnerTextAnnotationTag(text: String) {
        annotationView?.updateText(text: text)
        updateAnnotationView()
    }
    
}
