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
            elongatedAnnotationView?.setCornerRadius(radius: cornerRadius)
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
    var elongatedAnnotationView: UIView?
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
        elongatedAnnotationView?.snp.remakeConstraints({ (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(getLeftInset())
        })
        annotationView?.updateDiameter(self.intrinsicContentSize.height)
        
        titleEdgeInsets.left = getLeftInset()
    }
    
    open override var intrinsicContentSize : CGSize {
        let height = super.intrinsicContentSize.height //height is still calculated like a normal tagView
        let width = super.intrinsicContentSize.width + getLeftInset()
        return CGSize(width: width, height: height)
    }

    fileprivate func getLeftInset() -> CGFloat {
        //TODO: I have no fucking idea why the annotationViewDiameter works to make the tags look okay. It should be annotationViewDiameter + paddingX. But, for some reason, that overpads it. I can't figure it out, but somehow just setting annotationViewDiameter is bigger than the actual annoationView. I truly don't understand why these measurement are acting the way they do. The measurements that would be sense fo r this, aren't producing the right results. Right now, it looks good, but it's not mathematically sound.
        var leftInset: CGFloat = 0
        if let _ = annotationView {
            let annotationViewDiameter = super.intrinsicContentSize.height
            leftInset = annotationViewDiameter
        } else if let elongatedAnnotationView = elongatedAnnotationView {
            leftInset = elongatedAnnotationView.frame.width + paddingX
        }
        return leftInset
    }
}

//Extension for annotationViews with inner text
extension SpecialtyTagView {
    func convertToInnerTextAnnotationTag(text: String) {
        if let annotationView = annotationView {
            annotationView.removeFromSuperview()
            self.annotationView = nil
        }
        if let elongatedAnnotationView = elongatedAnnotationView {
            //elongated view already exists
        } else {
            //the elongatedAnnotationView doesn't exist yet
            createAnnotationViewWithInnerText(text: text)
        }
    }
    
    fileprivate func createAnnotationViewWithInnerText(text: String) {
        if text.characters.count <= 4 {
            annotationView = AnnotationView(diameter: self.intrinsicContentSize.height, color: TagViewProperties.borderColor, innerText: text)
            addAnnotationSubview(annotationView: annotationView!)
        } else {
            elongatedAnnotationViewWithText(text: text)
        }
    }
    
    fileprivate func elongatedAnnotationViewWithText(text: String) {
        elongatedAnnotationView = UIView()
        elongatedAnnotationView!.backgroundColor = TagViewProperties.borderColor
        elongatedAnnotationView?.isUserInteractionEnabled = false
        let innerLabel = createInnerLabel(text: text, superview: elongatedAnnotationView!)
        elongatedAnnotationView?.frame = CGRect(x: 0, y: 0, width: innerLabel.intrinsicContentSize.width, height: 0)
        self.addSubview(elongatedAnnotationView!)
        elongatedAnnotationView?.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(innerLabel.intrinsicContentSize.width + paddingX * 2)
        }
    }
    
    fileprivate func createInnerLabel(text: String, superview: UIView) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = TagViewProperties.tagInsidesColor
        superview.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return label
    }
}
