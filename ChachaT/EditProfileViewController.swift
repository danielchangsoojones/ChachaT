//
//  EditProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import STPopup
import EZSwiftExtensions

class EditProfileViewController: UIViewController {
    
    let currentUser = User.currentUser()
    
    @IBAction func theAgeButtonTapped(sender: UIButton) {
        DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                (birthday) -> Void in
                let calendar : NSCalendar = NSCalendar.currentCalendar()
                let now = NSDate()
                let ageComponents = calendar.components(.Year,
                                                        fromDate: birthday,
                                                        toDate: now,
                                                        options: [])
                sender.setTitle("\(ageComponents.year)", forState: .Normal)
                self.currentUser?.birthDate = birthday
                //saving birthdate in two places in database because it will make querying easier with tags.
                let tag = Tags()
                tag.birthDate = birthday
                tag.saveInBackground()
        }
    }
    
    @IBAction func theSaveButtonPressed(sender: UIBarButtonItem) {
//        currentUser?.fullName = theNameTextField.text
//        currentUser?.title = theTitleTextField.text
//        currentUser?.factOne = theFactOneTextField.text
//        currentUser?.factTwo = theFactTwoTextField.text
//        currentUser?.factThree = theFactThreeTextField.text
        currentUser?.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                print(error)
            }
        })
    }
    
    func imageTapped() {
        createBottomPicturePopUp()
    }
    
    func createBottomPicturePopUp() {
//        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.BottomPicturePopUpViewController.rawValue) as! BottomPicturePopUpViewController
//        vc.bottomPicturePopUpViewControllerDelegate = self
//        vc.profileImageSize = self.theProfileImageView.frame.size
//        let popup = STPopupController(rootViewController: vc)
//        popup.navigationBar.barTintColor = ChachaTeal
//        popup.navigationBar.tintColor = UIColor.whiteColor()
//        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        popup.style = STPopupStyle.BottomSheet
//        popup.presentInViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        helper()
//        theProfileImageView.userInteractionEnabled = true
//        theProfileImageView.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIStackView {
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 200, height: 200)
    }
}

//set up PhotoEditingView layout
extension EditProfileViewController{
    struct PhotoEditingViewConstants {
        static let numberOfViewsInInsideVerticalStackView : Int = 2
        static let numberOfViewsInInsideHorizontalStackView : Int = 3
        static let largeSquareRatioToScreenWidth : CGFloat = 1 / 2
        static let stackViewSpacing : CGFloat = 5
    }
    
    func helper() {
        let insideVerticalStackView = createInsideStackView(.Vertical, numberOfViews: PhotoEditingViewConstants.numberOfViewsInInsideVerticalStackView)
        let insideHorizontalStackView = createInsideStackView(.Horizontal, numberOfViews: PhotoEditingViewConstants.numberOfViewsInInsideHorizontalStackView)
        let largePhotoEditingView = PhotoEditingView(frame: CGRect(x: 0, y: 0, w: 200, h: 200))
//        let placeholder = UIView(frame: CGRect(x: 0, y: 0, w: 100, h: 100))
//        placeholder.backgroundColor = UIColor.blueColor()
        let horizontalStackView = createStackView(.Horizontal, views: [largePhotoEditingView, insideVerticalStackView])
//        print(horizontalStackView.intrinsicContentSize())
//        print(insideHorizontalStackView.intrinsicContentSize())
//        print(horizontalStackView.frame)
//        print(insideHorizontalStackView.frame)
        let masterStackView = createStackView(.Vertical, views: [horizontalStackView, insideHorizontalStackView])
        self.view.addSubview(masterStackView)
        masterStackView.snp_makeConstraints { (make) in
            make.trailing.leading.top.equalTo(self.view)
            make.height.equalTo(masterStackView.snp_width)
        }
    }
    
    func createInsideStackView(axis: UILayoutConstraintAxis, numberOfViews: Int) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: createMultiplePhotoEditingViews(numberOfViews))
        stackView.distribution = .FillEqually
        stackView.axis = axis
//        stackView.spacing = PhotoEditingViewConstants.stackViewSpacing
        return stackView
    }
    
    func createStackView(axis: UILayoutConstraintAxis, views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.distribution = .FillProportionally
//        stackView.spacing = PhotoEditingViewConstants.stackViewSpacing
        stackView.axis = axis
        return stackView
    }
    
    
    //create a way to make a bunch of PhotoEditingViews
    func createMultiplePhotoEditingViews(number: Int) -> [PhotoEditingView] {
        var viewArray : [PhotoEditingView] = []
        let frame = CGRect(x: 0, y: 0, w: 100, h: 100)
        for _ in number.range {
            viewArray.append(createPhotoEditingView(frame))
        }
        return viewArray
    }
    
    func createPhotoEditingView(frame: CGRect) -> PhotoEditingView {
        let photoEditingView = PhotoEditingView(frame: frame)
        return photoEditingView
    }
    //make this its own view file
    //set global variables for every PhotoEditingView
    //create a stackView to hold inside vertical stack
    //create a stackView to hold the inside vertical stack and largePhotoEditingView
    //create a stackView to hold inside horizontal stack
    //create a master stack view to put it all together
    
}

extension EditProfileViewController: BottomPicturePopUpViewControllerDelegate {
    func passImage(image: UIImage) {
//        theProfileImageView.image = image
//        let file = PFFile(name: "profileImage.jpg",data: UIImageJPEGRepresentation(theProfileImageView.image!, 0.6)!)
//        currentUser!.profileImage = file
    }
}
