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
    
    init(name: String, profileImage: AnyObject?, beginsWithTo: Bool) {
        super.init(frame: CGRect.zero)
        salutationLabelSetup(name: name, beginsWithTo: beginsWithTo)
        circleImageSetup(profileImage: profileImage)
        colonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func salutationLabelSetup(name: String, beginsWithTo: Bool) {
        var labelText = beginsWithTo ? "To" : "From"
        labelText += " \(name)"
        theSalutationLabel.text = labelText
        self.addSubview(theSalutationLabel)
        theSalutationLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    fileprivate func circleImageSetup(profileImage: AnyObject?) {
        let labelHeight: CGFloat = theSalutationLabel.size.height
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
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(theSalutationLabel)
            make.leading.equalTo(theCircleImageView.snp.trailing)
            //set the trailing, so the superview knows how big to make itself.
            make.trailing.equalToSuperview()
        }
    }
    
    
}
