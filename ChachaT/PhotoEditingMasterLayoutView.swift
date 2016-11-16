//
//  PhotoEditingMasterLayoutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol PhotoEditingDelegate {
    func photoPressed(_ photoNumber: Int, imageSize: CGSize, isPhotoWithImage: Bool)
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
    
    //Making units to work off of. The major units will be the height and width of one of the smaller pictures. The minor unit will be half of one spacing between each picture. The reason I choose half is so that the spacing along the edge of the master view will be smaller than the space between two pictures.
    
    func setLayout() {
        
        //One can adjust the spacing and the widths and Heights should resize accordingly to fill the frame of the PhotoEditingMasterLayoutView.
        let unitSpacing: CGFloat = 0.05 //Change THIS to get bigger or smaller spacings
        
        let spacing: CGFloat = unitSpacing * self.frame.width
        let unitWidth: CGFloat = ((1.0-2*unitSpacing)/3.0) * self.frame.width
        let unitHeight: CGFloat = ((1.0-2*unitSpacing)/3.0) * self.frame.height
        
        //Set heights, widths, x's and y's
        var widthArray = [unitWidth * 2.0 + spacing]
        for _ in 1...5 {
            widthArray.append(unitWidth)
        }
        
        var heightArray = [unitHeight * 2.0 + spacing]
        for _ in 1...5 {
            heightArray.append(unitHeight)
        }
        
        var xArray: [CGFloat] = [0.0]
        for _ in 1...3 {
            xArray.append(2.0*unitWidth + 2.0*spacing)
        }
        xArray += [unitWidth + spacing, 0.0]
        
        var yArray: [CGFloat] = [0.0, 0.0, unitHeight + spacing]
        for _ in 3...5 {
            yArray.append(2.0*unitHeight + 2.0*spacing)
        }
        
        //Create views
        for i in 0...5 {
            let frame = CGRect(x: xArray[i], y: yArray[i], w: widthArray[i], h: heightArray[i])
            let view = PhotoEditingView(frame: frame, number: i+1)
            view.tag = i + 1
            self.addSubview(view)
        }
        
        /*let largePhotoEditingView = createPhotoEditingView(CGRect(x: 0, y: 0, w: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension, h: PhotoEditingViewConstants.mainPhotoEditingViewSideDimension)) //the main photo that is surrounded by the siding
        let sidingStackViews = createSidingStackViews()
        let innerHorizontalStackView = createStackView(.horizontal, distribution: .fillProportionally, views: [largePhotoEditingView, sidingStackViews.verticalSiding])
        masterStackView = createStackView(.vertical, distribution: .fillProportionally, views: [innerHorizontalStackView, sidingStackViews.horizontalSiding])
        self.addSubview(masterStackView)
        masterStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }*/
    }
    
    
    
    //a sidingStackView is one of the rows, surrounding the large PhotoEditingView, on the outside of the square that holds the mini PhotoEditingViews.
    func createSidingStackViews() -> (verticalSiding: UIStackView, horizontalSiding: UIStackView) {
        let distribution : UIStackViewDistribution = .fillEqually
        let verticalSiding = createStackView(.vertical, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInVerticalSiding))
        let horizontalSiding = createStackView(.horizontal, distribution: distribution, views: createMultiplePhotoEditingViews(PhotoEditingViewConstants.numberOfViewsInHorizontalSiding))
        reorderHorizontalSidingPhotoNumbers(stackView: horizontalSiding)
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
    
    //Purpose: the number labels were backwards on the bottom row of the photo editing view, so this reorders them
    func reorderHorizontalSidingPhotoNumbers(stackView: UIStackView) {
        let numberArray = [6,5,4]
        
        for (index, subview) in stackView.arrangedSubviews.enumerated() {
            if let photoEditingView = subview as? PhotoEditingView {
                photoEditingView.setPhotoNumber(num: numberArray[index])
            }
        }
    }
    
    func photoTapped(_ sender: UIGestureRecognizer) {
        if let photoEditingView = sender.view as? PhotoEditingView {
            delegate?.photoPressed(photoEditingView.tag, imageSize: photoEditingView.theImageView.frame.size, isPhotoWithImage: photoEditingView.theNoPictureLabel.isHidden)
        }
    }
    
    func setNewImage(_ image: UIImage, photoNumber: Int) {
        let photoEditingSubviews = getSubviewsOfView(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(image: image) //should be only one photoEditingView that has any given tag
        }
    }
    
    func setNewImageFromFile(_ file: AnyObject, photoNumber: Int) {
        let photoEditingSubviews = getSubviewsOfView(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(file: file)
        }
    }
    
    func deleteImage(photoNumber: Int) {
        
        let photoEditingSubviews = getSubviewsOfView(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.deleteImage() //should be only one photoEditingView that has any given tag
        }
    }
    
    //Purpose: recursively find all subviews, including subviews of subviews, that are in a view.
    func getSubviewsOfView(_ view:UIView) -> [PhotoEditingView] {
        var photoEditingSubviewArray : [PhotoEditingView] = []
        
        for subview in view.subviews {
            photoEditingSubviewArray.append(subview as! PhotoEditingView)
        }
        
        return photoEditingSubviewArray
    }
    
}
