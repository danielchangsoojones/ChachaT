//
//  BottomButtonsView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

@objc protocol BottomButtonsDelegate {
    func nopeButtonPressed()
    func approveButtonPressed()
    @objc optional func messageButtonPressed()
}

class BottomButtonsView: UIView {
    fileprivate var view: UIView!
    
    @IBOutlet weak var theButtonStackView: UIStackView!
    @IBOutlet weak var theNopeButton: UIButton!
    @IBOutlet weak var theApproveButton: UIButton!
    
    var delegate: BottomButtonsDelegate?
    
    @IBAction func theNopeButtonPressed(_ sender: UIButton) {
        delegate?.nopeButtonPressed()
    }
    
    @IBAction func theApproveButtonPressed(_ sender: UIButton) {
        delegate?.approveButtonPressed()
    }
    
    func messageButtonPressed(sender: UIButton) {
        delegate?.messageButtonPressed!()
    }
    
    enum  Style {
        case filled
        case transparent
    }
    
    init(addMessageButton: Bool, delegate: BottomButtonsDelegate, style: Style) {
        super.init(frame: CGRect.zero)
        xibSetup()
        setBottomButtonImages(addMessageButton: addMessageButton, delegate: delegate, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func setBottomButtonImages(addMessageButton: Bool, delegate: BottomButtonsDelegate, style: Style) {
        if style == .filled {
            theNopeButton.setImage(#imageLiteral(resourceName: "filledInSkipButton"), for: .normal)
            theApproveButton.setImage(#imageLiteral(resourceName: "filledInApproveButton"), for: .normal)
        }
        self.delegate = delegate
        if addMessageButton {
            insertMessageButton(style: style)
        }
    }
    
    func insertMessageButton(style: Style) {
        let button = UIButton()
        switch style {
        case .filled:
            button.setImage(#imageLiteral(resourceName: "filledInMessageButton"), for: .normal)
        case .transparent:
            button.setImage(#imageLiteral(resourceName: "Message Airplane Button"), for: .normal)
        }
        button.addTarget(self, action: #selector(messageButtonPressed(sender:)), for: .touchUpInside)
        theButtonStackView.insertArrangedSubview(button, at: 1)
    }
    
    func invertApproveButton() {
        if let origImage = theApproveButton.currentImage {
            let tintImage = origImage.withRenderingMode(.alwaysTemplate)
            theApproveButton.setImage(tintImage, for: .normal)
            theApproveButton.tintColor = CustomColors.SilverChaliceGrey
        }
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type DescriptionDetailView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    fileprivate func xibSetup() {
        self.view = Bundle.main.loadNibNamed("BottomButtonsView", owner: self, options: nil)?[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
}



