//
//  AutoGrowingHorizontalScrollView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class AutoGrowingHorizontalScrollView: UIView {
    
    var theScrollView : UIScrollView = UIScrollView()
    var theContentView : UIView = UIView()
    var theStackView : UIStackView = UIStackView()
    
    init() {
        super.init(frame: CGRect.zero)
        scrollViewSetup()
    }
    
    fileprivate func scrollViewSetup() {
        self.addSubview(theScrollView)
        contentViewSetup()
        theScrollView.snp.makeConstraints { (make) in
            //the scroll view is snapped to the edges of the view because we want the whole view to be scrollable
            //so, it is just like normal autolayout, where we constrain it to the edges
            make.edges.equalTo(self)
        }
    }
    
    //The scroll view needs a content view because the scrollview calculates its size based upon its content. But, a scrollview can only pay attention to one subview(as in you can not have two views in a scroll view and expect it to calculate the correct size). So, to circumvent this problem. There is a single content view, where we can then put multiple subviews. The scrollview only sees this single content view, and is able to calculate its size correctly. In the content view, we use autolayout constraints like we normally would, and just make sure that the content view calculates its size from its inner subviews.
    fileprivate func contentViewSetup() {
        theScrollView.addSubview(theContentView)
        stackViewSetup()
        theContentView.snp.makeConstraints { (make) in
            //Tricky area: when the edges of theContentView are pinned to the scrollView. It is not like usual autolayout where theContentView grows to the size of theScrollView. It is telling theScrollView what theScrollView's content size should be.
            //So, it's not telling the ContentView to be the same frame size as the displayed ScrollView frame, it's rather telling Scrollview that the ContentView is its content and so if contentview is larger than the ScrollView frame then you get scrolling. This is the key to having a scrollView that grows with its contentSize. Ask Daniel Jones if more clarification needed.
            make.edges.equalTo(theScrollView)
            //We only want the scrollView to scroll horizontally. By setting the heights of theContentView and self.frame equal, we basically say the scrollView does not need to grow in the vertical direction.
            make.height.equalTo(self)
        }
    }
    
    //We add a stackView to the contentView because StackViews are great for automatically resizing. Everytime we add an arranged subview to the stack view, it will make the stackView grow and space in a proportional way.
    fileprivate func stackViewSetup() {
        theContentView.addSubview(theStackView)
        theStackView.snp.makeConstraints { (make) in
            //we set the edges of the Stack View to the contentView because it tells the Stack View to cover whatever area the contentView covers.
            //Additionally, by setting the edges of the Stack View to contentView, the content view is able to caclulate its own size because the constraint basically tell it how big the subviews are inside of theContentView.
            //So, when we add an arranged subview to the stack view, it makes the stack view grow to fit the new arranged subview, then the content view calculates the new size of the stack view, which allows the ContentView to know what size it should be. And then, the scrollView can calculate its size based upon theContentView size.
            make.edges.equalTo(theContentView)
        }
    }
    
    //Purpose: any type of view can be added to this scroll view, and it will grow accordingly.
    func addView(_ view: UIView) {
        //Remember: stackViews calculate things based off of intrinsic content size, so make sure the view passed has one set (labels have a defualt one for size of text, UIViews do not have ones set by defualt.)
        theStackView.addArrangedSubview(view)
    }
    
    func setStackViewSpacing(spacing: CGFloat) {
        theStackView.spacing = spacing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
