//
//  ScrollViewSearchView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewSearchView: UIView {
    
    @IBOutlet weak var theTagChosenListView: TagListView!
    @IBOutlet weak var theTagChosenHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    //constraint outlet
    @IBOutlet weak var theTagListViewWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        theTagChosenListView.addChosenTagListViewAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Purpose: I want to be able to have a scroll view that grows/shrinks as tags are added to it.
    //TODO: I probably need to update the tagview to have remove button enabled.
    func rearrangeSearchArea(tagView: TagView, extend: Bool) {
        let tagWidth = tagView.intrinsicContentSize().width
        let tagPadding : CGFloat = self.theTagChosenListView.marginX
        //TODO: Not having the X remove button is not accounted for in the framework, so that was why the extension was not working because it was not including the X button.
        if extend {
            //we are adding a tag, and need to make more room
            self.theTagListViewWidthConstraint.constant += tagWidth + tagPadding
        } else {
            //deleting a tag, so shrink view
            self.theTagListViewWidthConstraint.constant -= tagWidth + tagPadding
        }
        
        self.layoutIfNeeded()
        //checking to see if tags have outgrown screen because then I want it to slide the newest tag into focus
        if self.frame.width <= theTagChosenHolderView.frame.width {
            //I want the scroll view to go to a content offset where I only see the newest added tags.
            //So, I find out how big the TagHolderViewWidth has grown. Then, I see how big the screen is, and the difference is the area that is off the screen.
            //Therefore, I want to have contentOffset start at the end of the area that has been pushed off screen.
            let screenWidth = self.frame.size.width
            let chosenTagHolderViewWidth = theTagChosenHolderView.frame.size.width
            theScrollView.setContentOffset(CGPointMake(chosenTagHolderViewWidth - screenWidth, 0), animated: true)
        }
    }
    
    class func instanceFromNib() -> ScrollViewSearchView {
        // the nibName has to match your class file and your xib file
        return UINib(nibName: "ScrollViewSearchView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ScrollViewSearchView
    }
}
