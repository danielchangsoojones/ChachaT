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
    }
    
    fileprivate var theImageView: UIImageView!
    fileprivate var theInnerLabel: UILabel = UILabel()
    
    fileprivate var paddingX: CGFloat = 0
    
    init(diameter: CGFloat, color: UIColor, imageName: String) {
        super.init(diameter: diameter, color: color)
        imageViewSetup(imageName)
    }
    
    //Purpose: if we want the annotation view to have a label inside of it, like for age, we might want "24"
    init(diameter: CGFloat, color: UIColor, innerText: String, paddingX: CGFloat = 0) {
        super.init(diameter: diameter, color: color)
        self.paddingX = paddingX
        innerLabelSetup(labelText: innerText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func innerLabelSetup(labelText: String) {
        updateText(text: labelText)
        theInnerLabel.textColor = UIColor.white
        theInnerLabel.textAlignment = .center
        self.addSubview(theInnerLabel)
        theInnerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            //TODO: make this constant based upon something
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    func imageViewSetup(_ imageName: String) {
        theImageView = UIImageView(image: UIImage(named: imageName))
        theImageView.contentMode = .scaleAspectFit
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.width.equalTo(self).multipliedBy(AnnotationConstants.imageToCircleRatio)
        }
    }
    
    func updateImage(_ imageName: String) {
        theImageView.image = UIImage(named: imageName)
    }
    
    func updateText(text: String) {
        theInnerLabel.text = text
        if text.characters.count <= 4 {
            //make the annotationView a cirle with text
            self.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        } else {
            self.frame = CGRect(x: 0, y: 0, width: theInnerLabel.intrinsicContentSize.width + paddingX * 2, height: self.frame.height)
        }
    }
}

//An extension
extension AnnotationView {
    fileprivate func elongate(toWidth width: CGFloat) {
        //TODO: will I need to update constraints?
        self.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
    }

    
}
