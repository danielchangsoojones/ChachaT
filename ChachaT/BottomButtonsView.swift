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
    
    init(addMessageButton: Bool, delegate: BottomButtonsDelegate) {
        super.init(frame: CGRect.zero)
        xibSetup()
        self.delegate = delegate
        if addMessageButton {
            insertMessageButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func insertMessageButton() {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Message Airplane Button"), for: .normal)
        button.addTarget(self, action: #selector(messageButtonPressed(sender:)), for: .touchUpInside)
        theButtonStackView.insertArrangedSubview(button, at: 1)
        invertApproveButton()
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



