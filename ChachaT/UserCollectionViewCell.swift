//
//  UserCollectionViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    private struct Constants {
        static let textColor: UIColor = CustomColors.SilverChaliceGrey
        static let cornerRadius: CGFloat = 10
        static let imageInsetRatio: CGFloat = 0.10
    }
    
    static var reuseIdentifier: String = "userCollectionViewCell"
    
    var theImageView: UIImageView =  UIImageView()
    fileprivate var theNameLabel: UILabel = UILabel()
    
    var theUser: User? {
        didSet {
            nameLabelSetup()
            imageViewSetup()
        }
    }
    
    fileprivate func nameLabelSetup() {
        theNameLabel.text = theUser?.firstName
        theNameLabel.lineBreakMode = .byClipping
        theNameLabel.textAlignment = .center
        theNameLabel.textColor = Constants.textColor
        
        
        self.addSubview(theNameLabel)
        theNameLabel.snp.makeConstraints { (make) in
            let inset = self.frame.height * Constants.imageInsetRatio * 0.5
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(inset)
            make.width.equalTo(self).multipliedBy(0.75)
            let textHeight: CGFloat = theNameLabel.font.pointSize
            make.height.equalTo(textHeight)
        }
    }
    
    fileprivate func imageViewSetup() {
        theImageView.backgroundColor = CustomColors.BombayGrey
        theImageView.setCornerRadius(radius: Constants.cornerRadius)
        theImageView.contentMode = .scaleAspectFill
        theImageView.loadFromFile(theUser?.profileImage)
        theImageView.clipsToBounds = true
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            let inset = self.frame.height * Constants.imageInsetRatio
            make.leading.equalToSuperview().offset(inset)
            make.trailing.equalToSuperview().inset(inset)
            make.top.equalToSuperview().offset(inset)
            //Bug with snapkit, but I have to do a -inset instead of just using .inset(), to make it work
            make.bottom.equalTo(theNameLabel.snp.top).offset(-inset * 0.5)
        }
    }
}
