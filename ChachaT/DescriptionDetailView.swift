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
    
    var userOfTheCard: User? {
        didSet {
            setNameLabel(name: userOfTheCard?.fullName)
            setAgeLabel(age: userOfTheCard?.age?.toString)
            setTitleLabel(title: userOfTheCard?.title)
        }
    }
    
    //The coder initializer is used when creating from a storyboard, which is all we use this view for. If we ever wanted to develop it from code, then we would need to create an additional init()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        xibSetup()
    }
    
    //setters 
    //Once we set things, tthen we unhide them because we only want to show something if it has actually been set
    fileprivate func setNameLabel(name: String?) {
        setLabelText(label: theNameLabel, text: name)
    }
    
    fileprivate func setAgeLabel(age: String?) {
        if let age = age {
            let text = ", " + "\(age)"
            setLabelText(label: theAgeLabel, text: text)
        }
    }
    
    fileprivate func setTitleLabel(title: String?) {
        setLabelText(label: theTitleLabel, text: title)
    }
    
    fileprivate func setLabelText(label: UILabel, text: String?) {
        if let text = text {
            label.text = text
            label.isHidden = false
        }
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type DescriptionDetailView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    fileprivate func xibSetup() {
        self.view = Bundle.main.loadNibNamed("DescriptionDetailView", owner: self, options: nil)?[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
}
