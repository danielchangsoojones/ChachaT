//
//  PhotoEditingMasterLayoutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class PhotoEditingMasterLayoutView: UIView {
    private struct PhotoEditingViewConstants {
        //a sidingStackView is one of the rows, surrounding the large PhotoEditingView, on the outside of the square that holds the mini PhotoEditingViews.
        static let numberOfViewsInVerticalSiding : Int = 2
        static let numberOfViewsInHorizontalSiding : Int = 3
        static let miniViewtoMainViewRatio : CGFloat = 1 / 2
        //TODO: for some reason, when I make this variable < 50, it messes with the sizes of the mini views, not sure why because any number should theoretically work.
        static let mainPhotoEditingViewSideDimension : CGFloat = 100 //the real frame gets set by how wide the stackView gets snapkitted(constraints), this sets the intrinsicContentSize for things to calculate off of.
        static let stackViewSpacing : CGFloat = 5
    }
    
    init() {
        super.init(frame: CGRectZero)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        let sidingStackViews = createSidingStackViews()
        let largePhotoEditingView = createPhotoEditingView(CGRect(x: 0, y: 0, w: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension, h: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension)) //the main photo that is surrounded by the siding
        let innerHorizontalStackView = createStackView(.Horizontal, distribution: .FillProportionally, views: [largePhotoEditingView, sidingStackViews.verticalSiding])
        let masterStackView = createStackView(.Vertical, distribution: .FillProportionally, views: [innerHorizontalStackView, sidingStackViews.horizontalSiding])
        self.addSubview(masterStackView)
        masterStackView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    //a sidingStackView is one of the rows, surrounding the large PhotoEditingView, on the outside of the square that holds the mini PhotoEditingViews.
    func createSidingStackViews() -> (verticalSiding: UIStackView, horizontalSiding: UIStackView) {
        let distribution : UIStackViewDistribution = .FillEqually
        let verticalSiding = createStackView(.Vertical, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInVerticalSiding))
        let horizontalSiding = createStackView(.Horizontal, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInHorizontalSiding))
        return (verticalSiding, horizontalSiding)
    }
    
    func createStackView(axis: UILayoutConstraintAxis, distribution: UIStackViewDistribution, views: [UIView]) -> UIStackView {
        let stackView = PhotoEditingStackView(arrangedSubviews: views)
        stackView.distribution = distribution
        stackView.spacing = PhotoEditingViewConstants.stackViewSpacing
        stackView.axis = axis
        return stackView
    }
    
    func createMultiplePhotoEditingViews(number: Int) -> [PhotoEditingView] {
        var viewArray : [PhotoEditingView] = []
        let sideDimension : CGFloat = PhotoEditingViewConstants.mainPhotoEditingViewSideDimension * PhotoEditingViewConstants.miniViewtoMainViewRatio
        let frame = CGRect(x: 0, y: 0, w: sideDimension, h: sideDimension)
        for _ in number.range {
            viewArray.append(createPhotoEditingView(frame))
        }
        return viewArray
    }
    
    //a PhotoEditingView is the pictures that are clickable on the editingProfile Page, where you can add new photos to your profile.
    func createPhotoEditingView(frame: CGRect) -> PhotoEditingView {
        let photoEditingView = PhotoEditingView(frame: frame)
        photoEditingView.addTapGesture(target: self, action: #selector(PhotoEditingMasterLayoutView.photoTapped(_:)))
        return photoEditingView
    }
    
    func photoTapped(sender: UIGestureRecognizer) {
        if let photoEditingView = sender.view as? PhotoEditingView {
            //do something with the tag of each PhotoEditingView
        }
    }
    //TODO: make scrollView
    
}
