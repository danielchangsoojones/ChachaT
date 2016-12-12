//
//  NewIceBreakerView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class NewIceBreakerView: UIView {
    var theTextView: UITextView = UITextView()
    var theKeyboardBar: UIView = UIView()
    var theSaveButton: UIButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textViewSetup()
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
    

}

//keyboard bar extension
extension NewIceBreakerView {
    fileprivate func createKeyboardBar() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: 10, h: 60))
        createSaveButton(superview: view)
        topLineSetup(parentView: view)
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
            make.trailing.equalToSuperview().inset(10)
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
}
