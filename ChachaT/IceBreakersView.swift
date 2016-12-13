//
//  IceBreakersView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class IceBreakersView: UIView {
    
    var theTableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func tableViewSetup() {
        self.addSubview(theTableView)
        theTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
