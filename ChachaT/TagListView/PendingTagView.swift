//
//  PendingTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class PendingTagView: TagView {
    override init(title: String) {
        super.init(title: title)
        self.alpha = 0.4
        labelSetup()
    }
    
    fileprivate func labelSetup() {
        let label = UILabel()
        label.text = "pending..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: TagViewProperties.marginY)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
