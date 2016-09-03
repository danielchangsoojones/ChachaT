//
//  ProfilePhotoView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class ProfilePhotoView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var view: UIView!
    
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file. 
    
//    //Called when the view is created programmatically
//    override init(frame: CGRect) {
//        //setup any properties here
//        super.init(frame: frame)
//        
//        //Setup view from .xib file
//        xibSetup()
//    }
//    
//    //Called when the view is created via storyboard
//    required init?(coder aDecoder: NSCoder) {
//        // setup any properties here
//        
//        super.init(coder: aDecoder)
//        
//        // Setup view from .xib file
//        xibSetup()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("ProfilePhotoView", owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
//    func xibSetup() {
//        view = loadViewFromNib()
//        
//        // use bounds not frame or it'll be offset
//        view.frame = bounds
//        
//        // Make the view stretch with containing view
//        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
//        // Adding custom subview on top of our view (over any custom drawing > see note below)
//        addSubview(view)
//    }
//    
//    func loadViewFromNib() -> ProfilePhotoView {
//        let bundle = NSBundle(forClass: self.dynamicType)
//        let nib = UINib(nibName: "ProfilePhotoView", bundle: bundle)
//        let view = nib.instantiateWithOwner(nil, options: nil)[0] as! ProfilePhotoView
//        
//        return view
//    }
    
    
    

}
