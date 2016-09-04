//
//  PhotoEditingView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class PhotoEditingView: UIView {
    
    @IBOutlet var theView: UIView!
    @IBOutlet weak var theImageView: UIImageView!
    @IBOutlet weak var theNumberLabel: UILabel!
    
    
    //Called when the view is created programmatically
    init(frame: CGRect, number: Int) {
        super.init(frame: frame)
        xibSetup()
        theNumberLabel.text = number.toString
    }
    
    //Called when the view is created via storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override func intrinsicContentSize() -> CGSize {
        //need to override because usually UIViews have no intrinsic content size. 
        //But, we want the stackViews to size the view according to their frames, so we need to actually make the intrinsicContentSize = the frame of the View
        //.FillProportionatly of stackview sizes things based upon their intrinsicContentSize.
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        NSBundle.mainBundle().loadNibNamed("PhotoEditingView", owner: self, options: nil)[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(theView)
        theView.frame = self.bounds
    }
    
}
