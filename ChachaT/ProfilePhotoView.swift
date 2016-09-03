//
//  PhotoEditingView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class PhotoEditingView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file.
    @IBOutlet var view: UIView!

    
    //Called when the view is created programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    //Called when the view is created via storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        NSBundle.mainBundle().loadNibNamed("PhotoEditingView", owner: self, options: nil)[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
}
