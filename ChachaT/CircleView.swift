//
//  CircleView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircleView : UIView {
    var theImageView = UIImageView()
    
    init(file: AnyObject, cornerRadius: CGFloat) {
        super.init(frame: CGRectZero)
        theImageView.loadFromFile(file)
        imageViewSetup()
        makeCircular(theImageView, cornerRadius: cornerRadius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup() {
        self.addSubview(theImageView)
        theImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func makeCircular(view: UIView, cornerRadius: CGFloat) {
        theImageView.setCornerRadius(radius: cornerRadius)
        theImageView.clipsToBounds = true
    }
}