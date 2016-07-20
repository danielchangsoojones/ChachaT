//
//  SpecialtyTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SpecialtyTagView: TagView {
    
    //Purpose: add the two rectangular views to the tagview as well titles
    private func addSpecialtySubviews() {
        let yellowView: UIView = {
            $0.backgroundColor = .yellowColor()
            return $0
            // make sure to pass in UIView() here!
        }(UIView())
        self.addSubview(yellowView)
        yellowView.snp_makeConstraints { (make) in
            make.bottom.top.leading.equalTo(self)
            make.width.equalTo(5)
        }
    }
    
    override func setupView() {
        frame.size = intrinsicContentSize()
        addSubview(removeButton)
        addSpecialtySubviews()
        
        removeButton.tagView = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.addGestureRecognizer(longPress)
    }
    
    override public func intrinsicContentSize() -> CGSize {
        var size = titleLabel?.text?.sizeWithAttributes([NSFontAttributeName: textFont]) ?? CGSizeZero
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        if enableRemoveButton {
            size.width += removeButtonIconSize + paddingX
        }
        return size
    }
    
}
