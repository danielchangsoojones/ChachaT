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
    
    func innerLabelSetup(labelText: String) {
        //TODO: I'll have to figure out how to make the label go size to fit, so it doesn't just show ...
        theInnerLabel.text = labelText
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
    }
}
