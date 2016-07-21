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
    
    var tagTitle : String
    var specialtyTagTitle : String
    let specialtyTagTitlePadding : CGFloat = 5
    
    
    init(tagTitle: String, specialtyTagTitle: String) {
        self.tagTitle = tagTitle
        self.specialtyTagTitle = specialtyTagTitle
        super.init(frame: CGRectZero)
        setupView(tagTitle, specialtyTagTitle: specialtyTagTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSpecialtySubviews(tagTitle: String, specialtyTagTitle: String) {
        let yellowView: UIView = {
            $0.backgroundColor = .blueColor()
            return $0
        }(UIView())
        
        let theSpecialtyLabel: UILabel = {
            $0.text = specialtyTagTitle
            $0.textColor = textColor
            $0.font = textFont
            return $0
        }(UILabel())
        
        self.addSubview(yellowView)
        self.addSubview(theSpecialtyLabel)
        
        yellowView.snp_makeConstraints { (make) in
            make.bottom.top.leading.equalTo(self)
            make.width.equalTo(calculateSpecialtyTagAreaWidth())
        }
        theSpecialtyLabel.snp_makeConstraints { (make) in
            make.center.equalTo(yellowView)
        }
    }
    
    //Purpose: created this title inset because I want the button title to be inseted past the Specialty Area on the tag
    func setTitleEdgeInset() {
        self.setTitle(self.tagTitle, forState: .Normal)
        self.contentEdgeInsets = UIEdgeInsetsMake(0, calculateSpecialtyTagAreaWidth(), 0, 0)
    }
    
    func calculateSpecialtyTagAreaWidth() -> CGFloat {
        let specialtyTagTitleSize = self.specialtyTagTitle.sizeWithAttributes([NSFontAttributeName: textFont])
        return specialtyTagTitleSize.width + (specialtyTagTitlePadding * 2)
    }
    
    internal func setupView(tagTitle: String, specialtyTagTitle: String) {
        super.setupView()
        addSpecialtySubviews(tagTitle, specialtyTagTitle: specialtyTagTitle)
        setTitleEdgeInset()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let tagTitleSize = self.tagTitle.sizeWithAttributes([NSFontAttributeName: textFont])
        var totalSize = CGSizeZero
        totalSize.height = textFont.pointSize + paddingY * 2
        totalSize.width += tagTitleSize.width + calculateSpecialtyTagAreaWidth() + (paddingX * 2)
        if enableRemoveButton {
            totalSize.width += removeButtonIconSize + paddingX
        }
        return totalSize
    }
    
}
