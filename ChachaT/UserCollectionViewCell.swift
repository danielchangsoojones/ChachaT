//
//  UserCollectionViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String = "userCollectionViewCell"
    
    fileprivate var theImageView: UIImageView =  UIImageView()
    fileprivate var theNameLabel: UILabel = UILabel()
    
    var theUser: User? {
        didSet {
            nameLabelSetup()
            imageViewSetup()
        }
    }
    
    fileprivate func nameLabelSetup() {
        theNameLabel.text = theUser?.fullName
        self.addSubview(theNameLabel)
        theNameLabel.snp.makeConstraints { (make) in
            make.bottom.centerX.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.75)
        }
    }
    
    fileprivate func imageViewSetup() {
        theImageView.backgroundColor = CustomColors.BombayGrey
        theImageView.loadFromFile(theUser?.profileImage)
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(theNameLabel.snp.top)
        }
    }
}
