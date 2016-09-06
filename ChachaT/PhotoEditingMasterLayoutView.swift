//
//  PhotoEditingMasterLayoutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol PhotoEditingDelegate {
    func photoPressed(photoNumber: Int, imageSize: CGSize)
}

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
    
    var delegate : PhotoEditingDelegate?
    var masterStackView: UIStackView!
    var photoNumber : Int = 0
    
    init() {
        super.init(frame: CGRectZero)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
    }
    
    func setLayout() {
        let largePhotoEditingView = createPhotoEditingView(CGRect(x: 0, y: 0, w: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension, h: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension)) //the main photo that is surrounded by the siding
        let sidingStackViews = createSidingStackViews()
        let innerHorizontalStackView = createStackView(.Horizontal, distribution: .FillProportionally, views: [largePhotoEditingView, sidingStackViews.verticalSiding])
        masterStackView = createStackView(.Vertical, distribution: .FillProportionally, views: [innerHorizontalStackView, sidingStackViews.horizontalSiding])
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
        photoNumber = photoNumber + 1
        let photoEditingView = PhotoEditingView(frame: frame, number: photoNumber)
        photoEditingView.tag = photoNumber
        photoEditingView.addTapGesture(target: self, action: #selector(PhotoEditingMasterLayoutView.photoTapped(_:)))
        return photoEditingView
    }
    
    func photoTapped(sender: UIGestureRecognizer) {
        if let photoEditingView = sender.view as? PhotoEditingView {
            delegate?.photoPressed(photoEditingView.tag, imageSize: photoEditingView.theImageView.frame.size)
        }
    }
    
    func setNewImage(image: UIImage, photoNumber: Int) {
        let photoEditingSubviews = getSubviewsOfView(masterStackView)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.theImageView.image = image //should be only one photoEditingView that has any given tag
        }
    }
    
    //Purpose: recursively find all subviews, including subviews of subviews, that are in a view.
    func getSubviewsOfView(view:UIView) -> [PhotoEditingView] {
        var photoEditingSubviewArray : [PhotoEditingView] = []
        
        for subview in view.subviews {
            photoEditingSubviewArray = photoEditingSubviewArray + getSubviewsOfView(subview)
            
            if let subview = subview as? PhotoEditingView {
                photoEditingSubviewArray.append(subview)
            }
        }
        
        return photoEditingSubviewArray
    }
    
}
