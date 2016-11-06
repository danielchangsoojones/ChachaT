//
//  SuperEmptyStateView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class SuperEmptyStateView: UIView {
    struct EmptyStateConstants {
        static let labelTextColor: UIColor = CustomColors.SilverChaliceGrey
        static let buttonColor: UIColor = CustomColors.JellyTeal
    }
    
    var delegate: EmptyStateDelegate?
    
    init(delegate: EmptyStateDelegate) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.delegate = delegate
        stackViewSetup()
        labelSetup()
        buttonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var theButton: UIButton = UIButton()
    var theLabel: UILabel = UILabel()
    var theStackView: UIStackView = UIStackView()
    
    func stackViewSetup() {
        theStackView.axis = .vertical
        theStackView.distribution = .equalCentering
        self.addSubview(theStackView)
    }
    
    func buttonSetup() {
        theButton.setCornerRadius(radius: 10)
        theButton.layer.borderWidth = TagViewProperties.borderWidth
        theButton.layer.borderColor = EmptyStateConstants.buttonColor.cgColor
        theButton.setTitleColor(EmptyStateConstants.buttonColor, for: .normal)
    }
    
    func labelSetup() {
        theLabel.textColor = EmptyStateConstants.labelTextColor
        theLabel.numberOfLines = 0
        theLabel.textAlignment = .center
    }
}

protocol EmptyStateDelegate {
    func emptyStateButtonPressed()
}
