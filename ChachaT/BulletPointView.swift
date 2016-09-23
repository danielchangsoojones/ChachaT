//
//  BulletPointView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class BulletPointView: UIView {
    fileprivate struct BulletPointConstants {
        static let bulletPointColor : UIColor = CustomColors.JellyTeal
        static let bulletPointDiameter : CGFloat = 10
        static let circleViewLeadingOffset : CGFloat = 20
    }
    
    var theCircleView : CircleView!
    var theTextLabel : UILabel!

    init(text: String, width: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, w: width, h: 0))
        circleViewSetup()
        textLabelSetup(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func circleViewSetup() {
        theCircleView = CircleView(diameter: BulletPointConstants.bulletPointDiameter, color: BulletPointConstants.bulletPointColor)
        self.addSubview(theCircleView)
        theCircleView.snp_makeConstraints { (make) in
            //TODO: make these offsets based upon something
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(BulletPointConstants.circleViewLeadingOffset)
            make.height.width.equalTo(BulletPointConstants.bulletPointDiameter) //explicitly set height/width so it doesn't grow
        }
    }
    
    func textLabelSetup(_ text: String) {
        theTextLabel = UILabel(frame: CGRect(x: 0, y: 0, w: calculateTextLabelWidth(), h: CGFloat.max)) //setting the width and height, so we can calculate how tall the label will be for the intrinsicContentSize()
        theTextLabel.text = text
        theTextLabel.numberOfLines = 0 //so the textLabel can grow to multiple lines
        theTextLabel.sizeToFit() //want the label's size to fit, so then we can calculate the intrinsicContentSize
        self.addSubview(theTextLabel)
        theTextLabel.snp_makeConstraints { (make) in
            make.firstBaseline.equalTo(theCircleView.snp_bottom)
            make.leading.equalTo(theCircleView.snp_trailing) //if I add an offset, have to put offset in calculateTextLabelWidth
            make.trailing.equalTo(self)
            make.bottom.equalTo(self) //this makes the superview know its own height based upon how much the label has grown
        }
    }
    
    //StackViews calculate .FillProportionally based upon intrinsicContentSize, and normally, UIViews don't have intrinsicContentSize, but we override that.
    override var intrinsicContentSize : CGSize {
        //TODO: technically, the textLable height is offset a little bit from the top, so we need to factor that into the total height, although, stackViews do a proportional calculation to calculate how things stretch, so maybe not necessary, since theTextLabelHeight is the only changing variable
        let textLabelHeight = theTextLabel.frame.height
        return CGSize(width: 0, height: textLabelHeight)
    }
    
    func calculateTextLabelWidth() -> CGFloat {
        let superViewWidth = self.frame.width
        let circleViewWidth = theCircleView.frame.width
        let textLabelWidth = superViewWidth - BulletPointConstants.circleViewLeadingOffset - circleViewWidth
        return textLabelWidth
    }

}
