//
//  MessageSalutationView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class MessageSalutationView: UIView {
    
    fileprivate var theCircleImageView: CircularImageView!
    fileprivate var theSalutationLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
    }
    
    func setSalutationView(name: String, profileImage: AnyObject?, beginsWithTo: Bool) {
        salutationLabelSetup(name: name, beginsWithTo: beginsWithTo)
        circleImageSetup(profileImage: profileImage)
        colonSetup()
    }
    
    fileprivate func salutationLabelSetup(name: String, beginsWithTo: Bool) {
        var labelText = beginsWithTo ? "To" : "From"
        labelText += " \(name)"
        theSalutationLabel.text = labelText
        theSalutationLabel.textColor = CardMesageConstants.salutationTextColor
        self.addSubview(theSalutationLabel)
        theSalutationLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    fileprivate func circleImageSetup(profileImage: AnyObject?) {
        let labelHeight: CGFloat = theSalutationLabel.font.pointSize
        theCircleImageView = CircularImageView(file: profileImage, diameter: labelHeight * 2)
        self.addSubview(theCircleImageView)
        theCircleImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(theSalutationLabel)
            make.leading.equalTo(theSalutationLabel.snp.trailing).offset(10)
        }
    }
    
    fileprivate func colonSetup() {
        let label = UILabel()
        label.text = ":"
        label.textColor = CardMesageConstants.salutationTextColor
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(theSalutationLabel)
            make.leading.equalTo(theCircleImageView.snp.trailing)
            //set the trailing, so the superview knows how big to make itself.
            make.trailing.equalToSuperview()
        }
    }
    
    
}
