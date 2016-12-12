//
//  NewIceBreakerView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import RSKPlaceholderTextView

class NewIceBreakerView: UIView {
    struct IceBreakConstants {
        static let keyboardBarButtonsInset: CGFloat = 10
    }
    
    
    var theTextView:  RSKPlaceholderTextView = RSKPlaceholderTextView()
    var theKeyboardBar: UIView = UIView()
    var theSaveButton: UIButton = UIButton()
    var theCharCountLabel: UILabel = UILabel()
    var theTitleView: UIView = UIView()
    var theInfoIndicator: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textViewSetup()
        titleViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func textViewSetup() {
        theTextView.inputAccessoryView = createKeyboardBar()
        self.addSubview(theTextView)
        theTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setTextView(placeholder: String) {
        theTextView.placeholder = placeholder as NSString?
    }
}

//nav bar extension
extension NewIceBreakerView {
    fileprivate func titleViewSetup() {
        theTitleView.frame = CGRect(x: 0,y: 0,w: 100,h: 40)
        let titleLabel = addTitleLabel()
        theTitleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        let infoIndicator = infoIndicatorSetup()
        theTitleView.addSubview(infoIndicator)
        infoIndicator.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
        }
    }
    
    fileprivate func infoIndicatorSetup() -> UIButton {
        //TODO: make thuis an actual info Indicator
        theInfoIndicator = UIButton()
        theInfoIndicator.setImage(#imageLiteral(resourceName: "InfoIndicator"), for: .normal)
        return theInfoIndicator
    }
    
    fileprivate func addTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "New Ice Breaker"
        return titleLabel
    }
}

//keyboard bar extension
extension NewIceBreakerView {
    fileprivate func createKeyboardBar() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: 10, h: 60))
        createSaveButton(superview: view)
        topLineSetup(parentView: view)
        wordLimitLabelSetup(parentView: view)
        return view
    }
    
    fileprivate func createSaveButton(superview: UIView) {
        theSaveButton.setTitle("Save", for: .normal)
        theSaveButton.setCornerRadius(radius: 10)
        theSaveButton.backgroundColor = CustomColors.JellyTeal
        theSaveButton.setTitleColor(UIColor.white, for: .normal)
        superview.addSubview(theSaveButton)
        theSaveButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(IceBreakConstants.keyboardBarButtonsInset)
        }
    }
    
    func topLineSetup(parentView: UIView) {
        let line = createLine()
        parentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.trailing.top.leading.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func wordLimitLabelSetup(parentView: UIView) {
        theCharCountLabel = UILabel()
        theCharCountLabel.textColor = CustomColors.SilverChaliceGrey
        parentView.addSubview(theCharCountLabel)
        theCharCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(IceBreakConstants.keyboardBarButtonsInset)
        }
    }
}
