//
//  TitleView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class TitleView: UIView {
    private struct LayoutConstants {
        static let topOffset: CGFloat = 10
        static let sideOffset: CGFloat = 10
    }
    
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    init(title: String) {
        super.init(frame: CGRectZero)
        leftLabel.text = title
        setLeftLabelPosition()
    }
    
    convenience init(title: String, rightTitle: String) {
        self.init(title: title)
        rightLabel.text = rightTitle
        setRightLabelPosition()
    }
    
    func setLeftLabelPosition() {
        self.addSubview(leftLabel)
        leftLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(LayoutConstants.topOffset)
            make.leading.equalTo(self).offset(LayoutConstants.sideOffset)
        }
    }
    
    func setRightLabelPosition() {
        self.addSubview(rightLabel)
        rightLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(LayoutConstants.topOffset)
            make.trailing.equalTo(self).inset(LayoutConstants.sideOffset)
        }
    }
    
    func changeRightLabelTitle(newText: String) {
        rightLabel.text = newText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}