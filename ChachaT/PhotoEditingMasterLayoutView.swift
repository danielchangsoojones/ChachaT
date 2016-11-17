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
    func photoViewsHaveBeenPlaced()
}

struct PhotoEditingViewConstants {
    static let numberOfPhotoViews : Int = 6
}

class PhotoEditingMasterLayoutView: UIView {
    var delegate : PhotoEditingDelegate?
    
    //Making units to work off of. The major units will be the height and width of one of the smaller pictures. The minor unit will be half of one spacing between each picture. The reason I choose half is so that the spacing along the edge of the master view will be smaller than the space between two pictures.
    func setLayout() {
        
        let photoEditingViewsCount = getPhotoEditingViews(self).count
        if photoEditingViewsCount < PhotoEditingViewConstants.numberOfPhotoViews {
            //One can adjust the spacing and the widths and Heights should resize accordingly to fill the frame of the PhotoEditingMasterLayoutView.
            let unitSpacing: CGFloat = 0.05 //Change THIS to get bigger or smaller spacings
            
            let spacing: CGFloat = unitSpacing * self.frame.width
            let unitWidth: CGFloat = ((1.0 - 2 * unitSpacing)/3.0) * self.frame.width
            let unitHeight: CGFloat = ((1.0 - 2 * unitSpacing)/3.0) * self.frame.height
            
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
                xArray.append(2.0 * unitWidth + 2.0 * spacing)
            }
            xArray += [unitWidth + spacing, 0.0]
            
            var yArray: [CGFloat] = [0.0, 0.0, unitHeight + spacing]
            for _ in 3...5 {
                yArray.append(2.0 * unitHeight + 2.0 * spacing)
            }
            
            //Create views
            for i in 0...5 {
                let frame = CGRect(x: xArray[i], y: yArray[i], w: widthArray[i], h: heightArray[i])
                createPhotoEditingView(frame: frame, photoNumber: i + 1)
            }
            delegate?.photoViewsHaveBeenPlaced()
        }
    }
    
    fileprivate func createPhotoEditingView(frame: CGRect, photoNumber: Int) {
        let view = PhotoEditingView(frame: frame, number: photoNumber)
        view.tag = photoNumber
        view.addTapGesture(target: self, action: #selector(PhotoEditingMasterLayoutView.photoTapped(_:)))
        self.addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setLayout()
    }
    
    func photoTapped(_ sender: UIGestureRecognizer) {
        if let photoEditingView = sender.view as? PhotoEditingView {
            delegate?.photoPressed(photoEditingView.tag, imageSize: photoEditingView.theImageView.frame.size, isPhotoWithImage: photoEditingView.theNoPictureLabel.isHidden)
        }
    }
    
    func setNewImage(_ image: UIImage, photoNumber: Int) {
        let photoEditingSubviews = getPhotoEditingViews(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(image: image) //should be only one photoEditingView that has any given tag
        }
    }
    
    func setNewImageFromFile(_ file: AnyObject, photoNumber: Int) {
        let photoEditingSubviews = getPhotoEditingViews(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.setImage(file: file)
        }
    }
    
    func deleteImage(photoNumber: Int) {
        let photoEditingSubviews = getPhotoEditingViews(self)
        for subview in photoEditingSubviews where subview.tag == photoNumber {
            subview.deleteImage() //should be only one photoEditingView that has any given tag
        }
    }
    
    func getPhotoEditingViews(_ view:UIView) -> [PhotoEditingView] {
        var photoEditingSubviewArray : [PhotoEditingView] = []
        
        for subview in view.subviews {
            if let photoEditingView = subview as? PhotoEditingView {
                photoEditingSubviewArray.append(photoEditingView)
            }
        }
        
        return photoEditingSubviewArray
    }
}
