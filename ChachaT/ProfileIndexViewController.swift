//
//  ProfileIndexViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/4/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools

class ProfileIndexViewController: UIViewController {
    fileprivate struct ProfileIndexConstants {
        static let buttonImageInset: CGFloat = 20
        static let settingsTitle = "Settings"
    }
    
    @IBOutlet weak var theButtonStackView: UIStackView!
    @IBOutlet weak var theUpperBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: figure out how to have navigationBar not hidden across the whole app. I set nav bar hidden in backgroundAnimationController, and it makes it in every view controller, where I have to turn it back on. 
        self.navigationController?.isNavigationBarHidden = false
        settingsButtonSetup()
        profileButtonSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(.ProfileIndexToEditProfileSegue, sender: nil)
    }
    
    func profileButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(.ProfileIndexToCardDetailPageSegue, sender: nil)
    }
    
    func settingsButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(.ProfileIndexToSettingsPage, sender: nil)
    }
    
    func profileButtonSetup() {
        let profileBubble = CircularImageView(file: User.current()?.profileImage, diameter: 150)
        profileBubble.addTapGesture(target: self, action: #selector(ProfileIndexViewController.profileButtonPressed(_:)))
        theUpperBackgroundView.addSubview(profileBubble)
        profileBubble.snp.makeConstraints { (make) in
            make.center.equalTo(theUpperBackgroundView)
        }
        editProfileButtonSetup(profileBubble)
    }
    
    func editProfileButtonSetup(_ profileBubble: UIView) {
        let editButton = CircleView(diameter: 50, color: UIColor.white)
        editButton.addTapGesture(target: self, action: #selector(ProfileIndexViewController.editButtonPressed(_:)))
        theUpperBackgroundView.addSubview(editButton)
        editButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(profileBubble)
            make.trailing.equalTo(profileBubble)
        }
        let imageView = UIImageView(image: UIImage(named: "EditingPencil"))
        editButton.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalTo(editButton)
            make.height.width.equalTo(editButton.frame.height - ProfileIndexConstants.buttonImageInset)
        }
    }
    
    func settingsButtonSetup() {
        let buttonView = createButtonView()
        buttonView.addTapGesture(target: self, action: #selector(ProfileIndexViewController.settingsButtonPressed(_:)))
        
        //By setting the height for the circleButton and label, and then constraining these to the buttonView, the buttonView is able to calculate its necessary size.
        //TODO: put image name in struct above
        let circleButton = createButtonCircle(UIImage(named: "SettingsGear")!)
        buttonView.addSubview(circleButton)
        circleButton.snp.makeConstraints { (make) in
            make.top.equalTo(buttonView)
            make.leading.trailing.equalTo(buttonView)
        }
        
        let label = createButtonLabel(ProfileIndexConstants.settingsTitle)
        buttonView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.bottom.equalTo(buttonView)
            make.top.equalTo(circleButton.snp.bottom)
            make.centerX.equalTo(buttonView)
        }
        
        theButtonStackView.addArrangedSubview(buttonView)
    }
    
    fileprivate func createButtonView() -> UIView {
        let theView = UIView()
        return theView
    }
    
    fileprivate func createButtonLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }
    
    fileprivate func createButtonCircle(_ image: UIImage) -> UIView {
        //TODO: make the constant mean something
        let circleView = CircleView(diameter: 100, color: CustomColors.JellyTeal)
        let imageView = UIImageView(image: image)
        circleView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalTo(circleView)
            //TODO: make the constant mean something
            make.height.width.equalTo(circleView.frame.height - 20)
        }
        return circleView
    }

}

extension ProfileIndexViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case ProfileIndexToCardDetailPageSegue
        case ProfileIndexToEditProfileSegue
        case ProfileIndexToSettingsPage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .ProfileIndexToCardDetailPageSegue:
            //TODO: make the nav bar disappear, and they can just hit the back button on the image.
            let cardDetailVC = segue.destination as! CardDetailViewController
            cardDetailVC.isViewingOwnProfile = true
            cardDetailVC.userOfTheCard = User.current()
        default:
            break
        }
    }
}


