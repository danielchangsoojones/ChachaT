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
    @IBOutlet weak var theCircleBackground: UIView!
    var theNoPictureLabel = UILabel()
    
    //Constraints
    @IBOutlet weak var theCircleBackgroundWidthConstraint: NSLayoutConstraint!
    //Called when the view is created programmatically
    
    init(frame: CGRect, number: Int) {
        super.init(frame: frame)
        xibSetup()
        theNoPictureLabelSetup()
        theCircleBackground.setCornerRadius(radius: theCircleBackgroundWidthConstraint.constant / 2)
        self.setCornerRadius(radius: 10)
        theNumberLabel.text = number.toString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize : CGSize {
        //need to override because usually UIViews have no intrinsic content size. 
        //But, we want the stackViews to size the view according to their frames, so we need to actually make the intrinsicContentSize = the frame of the View
        //.FillProportionatly of stackview sizes things based upon their intrinsicContentSize.
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        theView = Bundle.main.loadNibNamed("PhotoEditingView", owner: self, options: nil)![0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(theView)
        theView.frame = self.bounds
    }
    
    fileprivate func theNoPictureLabelSetup() {
        theNoPictureLabel.text = "Add \nPhoto"
        theNoPictureLabel.textColor = UIColor.white
        theNoPictureLabel.textAlignment = .center
        theNoPictureLabel.font = UIFont.systemFont(ofSize: 10)
        theNoPictureLabel.numberOfLines = 2
        theImageView.addSubview(theNoPictureLabel)
        theNoPictureLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func setImage(image: UIImage) {
        theImageView.image = image
        theNoPictureLabel.isHidden = true
    }
    
    func setImage(file: AnyObject) {
        theImageView.loadFromFile(file)
        theNoPictureLabel.isHidden = true
    }
}
