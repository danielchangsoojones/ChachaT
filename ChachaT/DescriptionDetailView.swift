//
//  DescriptionDetailView.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class DescriptionDetailView: UIView {
    fileprivate var view: UIView!
    
    @IBOutlet weak fileprivate var theNameLabel: UILabel!
    @IBOutlet weak fileprivate var theAgeLabel: UILabel!
    @IBOutlet weak fileprivate var theTitleLabel: UILabel!
    
    //The coder initializer is used when creating from a storyboard, which is all we use this view for. If we ever wanted to develop it from code, then we would need to create an additional init()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        xibSetup()
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type DescriptionDetailView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    fileprivate func xibSetup() {
        self.view = Bundle.main.loadNibNamed("AboutView", owner: self, options: nil)?[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    //setters 
    func setNameLabel(text: String?) {
        setLabelText(label: theNameLabel, text: text)
    }
    
    func setAgeLabel(text: String?) {
        setLabelText(label: theAgeLabel, text: text)
    }
    
    func setTitleLabel(text: String?) {
        setLabelText(label: theTitleLabel, text: text)
    }
    
    fileprivate func setLabelText(label: UILabel, text: String?) {
        if let text = text {
            label.text = text
            label.isHidden = false
        }
    }
}
