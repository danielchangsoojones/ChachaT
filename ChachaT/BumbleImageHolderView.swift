//
//  BumbleImageHolderView.swift
//  BumbleTesting
//
//  Created by Daniel Jones on 12/5/16.
//  Copyright © 2016 Daniel Jones. All rights reserved.
//

import UIKit
import SnapKit

class BumbleImageHolderView: UIView {
    var theImageView: UIImageView!
    
    init(image: UIImage, frame: CGRect, haveBottomInset: Bool) {
        super.init(frame: frame)
        imageViewSetup(image: image)
        addImageView(haveBottomInset: haveBottomInset)
    }
    
    init(file: AnyObject?, frame: CGRect, haveBottomInset: Bool) {
        super.init(frame: frame)
        imageViewSetup(file: file)
        addImageView(haveBottomInset: haveBottomInset)
    }
    
    private func imageViewSetup(file: AnyObject?) {
        theImageView = UIImageView()
        theImageView.loadFromFile(file)
    }
    
    private func imageViewSetup(image: UIImage) {
        theImageView = UIImageView(image: image)
    }
    
    private func addImageView(haveBottomInset: Bool) {
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(haveBottomInset ? 3 : 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }

}
