//
//  MatchesScrollAreaView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class MatchesScrollAreaView: UIView {
    private struct MatchesScrollConstants {
        static let circleViewSize : CGSize = CGSize(width: 20, height: 20)
    }
    
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file.
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var theStackView: UIStackView!
    
    init() {
        super.init(frame: CGRectZero)
        xibSetup()
        addMatchView("Daniel", imageFile: User.currentUser()!.profileImage!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        //this name must match the nib file name
        NSBundle.mainBundle().loadNibNamed("MatchesScrollAreaView", owner: self, options: nil)[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    func addMatchView(name: String, imageFile: AnyObject) {
        let circleProfileView = CircleProfileView(name: name, circleViewSize: MatchesScrollConstants.circleViewSize, imageFile: imageFile)
        theStackView.addArrangedSubview(circleProfileView)
    }

}
