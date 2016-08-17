//
//  SpecialtyTagEnviromentHolderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

public enum SpecialtyTagEnviroments {
    case DistanceSlider
    case AgeRangeSlider
    case StackViewButtons
    case CreateNewTag
}

protocol SpecialtyTagEnviromentHolderViewDelegate {
    func unhideChoicesTagListView()
    func createNewPersonalTag(title: String)
}

class SpecialtyTagEnviromentHolderView: UIView {
    
    var theSpecialtyView: UIView?
    let theDoneButton: UIButton = {
        $0.setTitleColor(UIColor.blueColor(), forState: .Normal)
        $0.setTitle("Done", forState: .Normal)
        return $0
    }(UIButton())
    let theTitleLabel: UILabel = {
        $0.textColor = UIColor.blackColor()
        return $0
    }(UILabel())
    let theStackView: UIStackView = {
        $0.alignment = .Center
        $0.axis = .Vertical
        $0.distribution = .EqualSpacing
        return $0
    }(UIStackView())
//    let tagListView = ChachaChosenTagListView()
    
    var createTagButtonText: String?
    var createdTag: TagView?
    var delegate: SpecialtyTagEnviromentHolderViewDelegate?
    
    func doneButtonTapped(sender: UIButton!) {
        if sender.titleLabel?.text == createTagButtonText {
            //we re-create the tagView with the original tags and then the created tag is already kept in
            if let createdTag = createdTag {
                if let title = createdTag.currentTitle {
                    //the user has made a tag that was never in the database. Need to add the tag to the tagChoicesView and also have it in array to be saved to database.
                    delegate?.createNewPersonalTag(title)
                }
            }
        }
        self.removeFromSuperview()
        delegate?.unhideChoicesTagListView()
    }
    
    init(specialtyTagEnviroment: SpecialtyTagEnviroments) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        switch specialtyTagEnviroment {
        case .DistanceSlider:
            self.theTitleLabel.text = "Distance Radius"
        case .AgeRangeSlider:
            theSpecialtyView = AgeDoubleRangeSliderView()
            self.theTitleLabel.text = "Age Range"
        case .StackViewButtons:
            //had to pass this one in another initializer, since I want there to be some parameters passed through
            break
        case .CreateNewTag:
//            theSpecialtyView = tagListView
            theTitleLabel.text = "That tag doesn't exist yet"
        }
        createStackView()
    }
    
    init(filterCategory: String, addNoneButton: Bool, stackViewButtonDelegate: StackViewTagButtonsDelegate, pushOneButton: Bool) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
//        self.theSpecialtyView = StackViewTagButtons(filterCategory: filterCategory, addNoneButton: addNoneButton, delegate: stackViewButtonDelegate, pushOneButton: pushOneButton)
        self.theTitleLabel.text = filterCategory
        createStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createStackView() {
        self.addSubview(theStackView)
        theStackView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addItemsToStackView()
    }
    
    func addItemsToStackView() {
        theStackView.addArrangedSubview(theTitleLabel)
        if let theSpecialtyView = theSpecialtyView {
            theStackView.addArrangedSubview(theSpecialtyView)
            theSpecialtyView.snp_makeConstraints(closure: { (make) in
                make.leading.trailing.equalTo(theStackView)
                make.height.equalTo(30)
            })
        }
        theStackView.addArrangedSubview(theDoneButton)
        theDoneButton.addTarget(self, action: #selector(doneButtonTapped), forControlEvents: .TouchUpInside)
    }
    
    func updateTagListView(searchText: String) {
//        tagListView.removeAllTags()
//        createdTag = tagListView.addTag(searchText)
    }
    
//    func createDistanceSliderView() {
//        let theDistanceSliderView = DistanceSliderView()
//        //had to set the initial value for the slider here because not loading when I put in the slider view class
//        theDistanceSliderView.theDistanceSlider.setValue(50.0, animated: false)
//        theSpecialtyView = theDistanceSliderView
//    }
    
    func setButtonText(text: String) {
        createTagButtonText = text
        theDoneButton.setTitle(createTagButtonText, forState: .Normal)
    }
    
}
