//
//  PendingTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class PendingTagView: TagView {
    
    var theTopLabel: UILabel = UILabel()
    var isApproved: Bool = false
    
    init(title: String, topLabelTitle: String) {
        super.init(title: title)
        self.alpha = 0.4
        theTopLabel.text = topLabelTitle
        labelSetup()
    }
    
    func approve() {
        self.alpha = 1
        isApproved = true
        theTopLabel.removeFromSuperview()
    }
    
    fileprivate func labelSetup() {
        theTopLabel.textAlignment = .center
        theTopLabel.text = "butter"
        theTopLabel.font = UIFont.systemFont(ofSize: TagViewProperties.marginY)
        self.addSubview(theTopLabel)
        theTopLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
