//
//  TutorialViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/7/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    enum TutorialPage: Int {
        case initialPage
        case secondPage
        case thirdPage
        case finalPage
        
        var image: UIImage {
            switch self {
            case .initialPage:
                return #imageLiteral(resourceName: "tutorialFirstPage")
            case .secondPage:
                return #imageLiteral(resourceName: "tutorialSecondPage")
            case .thirdPage:
                return #imageLiteral(resourceName: "tutorialPageThree")
            case .finalPage:
                return #imageLiteral(resourceName: "tutorialFinalPage")
            }
        }
    }
    
    var theImageView: UIImageView = UIImageView()
    var theButtonStackView: UIStackView = UIStackView()
    
    var tutorialPage: TutorialPage = .initialPage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewSetup()
    }
    
    func imageViewSetup() {
        theImageView.image = tutorialPage.image
        self.view.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if tutorialPage == .finalPage {
            createStackView()
        } else {
            theImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            theImageView.addGestureRecognizer(tap)
        }
    }
    
    func imageTapped() {
        self.segueToNextTutorialPage()
    }

    func segueToNextTutorialPage() {
        let nextPageNumber: Int = tutorialPage.rawValue + 1
        let nextTutorialPage: TutorialPage = TutorialPage(rawValue: nextPageNumber) ?? .finalPage
        
        let tutorialVC = TutorialViewController()
        tutorialVC.tutorialPage = nextTutorialPage
        presentVC(tutorialVC)
    }
    
    fileprivate func createStackView() {
        theButtonStackView.axis = .horizontal
        theButtonStackView.distribution = .equalCentering
        theButtonStackView.alignment = .center
        self.view.addSubview(theButtonStackView)
        theButtonStackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.view.frame.width * 0.15)
        }
        createFinalButtons()
    }
    
    fileprivate func createFinalButtons() {
        createButton(text: "Sign \nUp", selector: #selector(signUpButtonPressed))
        createButton(text: "Keep \nSearching", selector: #selector(keepSearchingButtonPressed))
    }
    
    fileprivate func createButton(text: String, selector: Selector) {
        let circleView = CircleView(diameter: 100, color: UIColor.white)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        circleView.addGestureRecognizer(tap)
        
        let label = UILabel()
        label.textColor = CustomColors.JellyTeal
        label.font = UIFont(name: "Marker Felt", size: 30)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = text
        circleView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        theButtonStackView.addArrangedSubview(circleView)
    }
    
    func signUpButtonPressed() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
        presentVC(signUpVC)
    }
    
    func keepSearchingButtonPressed() {
        AnonymousDataStore().enableAutomaticUser()
        AnonymousDataStore().saveAnonymousUser()
        let navController = ChachaNavigationViewController()
        
        //set up the rootviewController
        let storyboard = UIStoryboard(name: "Filtering", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchTagsViewController") as! SearchTagsViewController
        navController.viewControllers = [searchViewController]
        presentVC(navController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
