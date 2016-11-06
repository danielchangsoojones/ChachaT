//
//  MainPageEmptyStateView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class MainPageEmptyStateView: SuperEmptyStateView {
    fileprivate struct EmptyMainPageConstants {
        static let exhaustedDatabaseLabelText: String = "You have swiped everyone in the database. Come back later when we have more users or:"
        static let exhaustedDatabaseButtonText: String = "Search Users"
    }
    
    override func stackViewSetup() {
        super.stackViewSetup()
        theStackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(150)
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    override func labelSetup() {
        super.labelSetup()
        theLabel.text = EmptyMainPageConstants.exhaustedDatabaseLabelText
        theStackView.addArrangedSubview(theLabel)
    }
    
    override func buttonSetup() {
        super.buttonSetup()
        let buttonTitle = EmptyMainPageConstants.exhaustedDatabaseButtonText
        theButton.setTitle(buttonTitle, for: .normal)
        theButton.addTarget(self, action: #selector(buttonAction), for: .allEvents)
        theStackView.addArrangedSubview(theButton)
    }
    
    func buttonAction() {
        delegate?.emptyStateButtonPressed()
    }
}


