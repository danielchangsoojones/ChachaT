//
//  AnnotationView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AnnotationView: CircleView {
    fileprivate struct AnnotationConstants {
        static let imageToCircleRatio : CGFloat = 0.75
        static let minimumWordCountForCircle: Int = 4
    }
    
    fileprivate var theImageView: UIImageView = UIImageView()
    fileprivate var theInnerLabel: UILabel = UILabel()
    
    init(diameter: CGFloat, color: UIColor, imageName: String) {
        super.init(diameter: diameter, color: color)
        imageViewSetup(imageName)
    }
    
    //Purpose: if we want the annotation view to have a label inside of it, like for age, we might want "24"
    init(diameter: CGFloat, color: UIColor, innerText: String) {
        super.init(diameter: diameter, color: color)
        innerLabelSetup(labelText: innerText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup(_ imageName: String) {
        theImageView.image = UIImage(named: imageName)
        theImageView.contentMode = .scaleAspectFit
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.width.equalTo(self).multipliedBy(AnnotationConstants.imageToCircleRatio)
        }
    }
    
    func updateImage(_ imageName: String) {
        if !theImageView.isDescendant(of: self) {
            //the innerLabel hasn't been added to the view yet
            imageViewSetup(imageName)
        }
        theInnerLabel.removeFromSuperview()
        updateDiameter(self.diameter)
        theImageView.image = UIImage(named: imageName)
    }
    
    override func updateDiameter(_ diameter: CGFloat) {
        if let text = theInnerLabel.text, text.characters.count > AnnotationConstants.minimumWordCountForCircle && theInnerLabel.isDescendant(of: self) {
            //we only want to elongate the frame if the character count is greater than the min, and if theInnerLabel is actually supposed to be shown
            elongateFrame(text: text)
        } else {
            self.diameter = diameter
            super.updateDiameter(diameter)
        }
    }
}

//An extension for text within AnnotationView
extension AnnotationView {
    fileprivate func innerLabelSetup(labelText: String) {
        theInnerLabel.textColor = UIColor.white
        theInnerLabel.textAlignment = .center
        self.addSubview(theInnerLabel)
        updateText(text: labelText)
        theInnerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func updateText(text: String) {
        if !theInnerLabel.isDescendant(of: self) {
            //the innerLabel hasn't been added to the view yet
            innerLabelSetup(labelText: text)
        }
        theInnerLabel.text = text
        theImageView.removeFromSuperview()
        updateDiameter(diameter)
    }
    
    fileprivate func elongateFrame(text: String) {
        self.frame = CGRect(x: 0, y: 0, width: theInnerLabel.intrinsicContentSize.width + TagViewProperties.paddingX, height: self.frame.height)
    }
}
