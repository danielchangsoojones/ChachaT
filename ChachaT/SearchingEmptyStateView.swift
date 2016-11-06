//
//  SearchingEmptyStateView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class SearchingEmptyStateView: SuperEmptyStateView {
    fileprivate struct SearchEmptyConstants {
        static let labelText: String = "No users found"
        static let buttonText: String = "Clear Search"
    }
    
    override init(delegate: EmptyStateDelegate) {
        super.init(delegate: delegate)
        topLineSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func topLineSetup() {
        let line = UIView()
        line.backgroundColor = CustomColors.SilverChaliceGrey
        line.alpha = 0.5
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.trailing.top.leading.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
    
    override func stackViewSetup() {
        super.stackViewSetup()
        theStackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    override func labelSetup() {
        super.labelSetup()
        theLabel.text = SearchEmptyConstants.labelText
        theStackView.addArrangedSubview(theLabel)
    }
    
    override func buttonSetup() {
        super.buttonSetup()
        theButton.setTitle(SearchEmptyConstants.buttonText, for: .normal)
        theButton.addTarget(self, action: #selector(buttonAction), for: .allEvents)
        theStackView.addArrangedSubview(theButton)
    }
    
    func buttonAction() {
        delegate?.emptyStateButtonPressed()
    }
}
