//
//  PhotoEditingMasterLayoutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol PhotoEditingDelegate {
    func photoPressed(_ photoNumber: Int, imageSize: CGSize)
}

struct PhotoEditingViewConstants {
    //a sidingStackView is one of the rows, surrounding the large PhotoEditingView, on the outside of the square that holds the mini PhotoEditingViews.
    static let numberOfViewsInVerticalSiding : Int = 2
    static let numberOfViewsInHorizontalSiding : Int = 3
    static let miniViewtoMainViewRatio : CGFloat = 1 / 2
    //TODO: for some reason, when I make this variable < 50, it messes with the sizes of the mini views, not sure why because any number should theoretically work.
    static let mainPhotoEditingViewSideDimension : CGFloat = 100 //the real frame gets set by how wide the stackView gets snapkitted(constraints), this sets the intrinsicContentSize for things to calculate off of.
    //Since I have stackviews within stackViews, I was getting a broken autolayout warning. This was because the stackView didn't know it's horizontal size when this was loaded, so the horizontal stack view spacing (with an Apple-given 1000 priority) was causing ambigious constraints. So, in the Profile storyboard, I had to give the PhotoEditingMasterLayoutView a given width (with a low 250 priority), just so the compiler knew, upon load, that the width wasn't 0. Ask Daniel Jones if you run into the problem of a autolayout problem from this view.
    static let stackViewSpacing : CGFloat = 10
    static let numberOfPhotoViews : Int = 6
}

class PhotoEditingMasterLayoutView: UIView {
    var delegate : PhotoEditingDelegate?
    var masterStackView: UIStackView!
    var photoNumber : Int = 0
    
    init() {
        super.init(frame: CGRect.zero)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
    }
    
    func setLayout() {
        let largePhotoEditingView = createPhotoEditingView(CGRect(x: 0, y: 0, w: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension, h: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension)) //the main photo that is surrounded by the siding
        let sidingStackViews = createSidingStackViews()
        let innerHorizontalStackView = createStackView(.horizontal, distribution: .fillProportionally, views: [largePhotoEditingView, sidingStackViews.verticalSiding])
        masterStackView = createStackView(.vertical, distribution: .fillProportionally, views: [innerHorizontalStackView, sidingStackViews.horizontalSiding])
        self.addSubview(masterStackView)
        masterStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    //a sidingStackView is one of the rows, surrounding the large PhotoEditingView, on the outside of the square that holds the mini PhotoEditingViews.
    func createSidingStackViews() -> (verticalSiding: UIStackView, horizontalSiding: UIStackView) {
        let distribution : UIStackViewDistribution = .fillEqually
        let verticalSiding = createStackView(.vertical, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInVerticalSiding))
        let horizontalSiding = createStackView(.horizontal, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInHorizontalSiding))
        return (verticalSiding, horizontalSiding)
    }
    
    func createStackView(_ axis: UILayoutConstraintAxis, distribution: UIStackViewDistribution, views: [UIView]) -> UIStackView {
        let stackView = PhotoEditingStackView(arrangedSubviews: views)
        stackView.distribution = distribution
        stackView.spacing = PhotoEditingViewConstants.stackViewSpacing
        stackView.axis = axis
        return stackView
    }
    
    func createMultiplePhotoEditingViews(_ number: Int) -> [PhotoEditingView] {
        var viewArray : [PhotoEditingView] = []
        let sideDimension : CGFloat = PhotoEditingViewConstants.mainPhotoEditingViewSideDimension * PhotoEditingViewConstants.miniViewtoMainViewRatio
        let frame = CGRect(x: 0, y: 0, w: sideDimension, h: sideDimension)
        for _ in number.range {
            viewArray.append(createPhotoEditingView(frame))
        }
        return viewArray
    }
    
    //a PhotoEditingView is the pictures that are clickable on the editingProfile Page, where you can add new photos to your profile.
    func createPhotoEditingView(_ frame: CGRect) -> PhotoEditingView {
        photoNumber = photoNumber + 1
        let photoEditingView = PhotoEditingView(frame: frame, number: photoNumber)
        photoEditingView.tag = photoNumber
        photoEditingView.addTapGesture(target: self, action: #selector(PhotoEditingMasterLayoutView.photoTapped(_:)))
        return photoEditingView
    }
    
    func photoTapped(_ sender: UIGestureRecognizer) {
        if let photoEditingView = sender.view as? PhotoEditingView {
            delegate?.photoPressed(photoEditingView.tag, imageSize: photoEditingView.theImageView.frame.size)
        }
    }
    
    func setNewImage(_ image: UIImage, photoNumber: Int) {
        let photoEditingSubviews = getSubviewsOfView(masterStackView)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(image: image) //should be only one photoEditingView that has any given tag
        }
    }
    
    func setNewImageFromFile(_ file: AnyObject, photoNumber: Int) {
        let photoEditingSubviews = getSubviewsOfView(masterStackView)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(file: file)
        }
    }
    
    //Purpose: recursively find all subviews, including subviews of subviews, that are in a view.
    func getSubviewsOfView(_ view:UIView) -> [PhotoEditingView] {
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
