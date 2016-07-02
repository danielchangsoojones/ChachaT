//
//  AddingTagsToProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TagListView

class AddingTagsToProfileViewController: FilterTagViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        changeTheChoicesTagView()
        tagChoicesView.delegate = self
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func changeTheChoicesTagView() {
        //the user should be able to remove his/her tags because now they are editing them
        tagChoicesView.enableRemoveButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddingTagsToProfileViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if sender.tag == 1 {
            //the remove button from theChoicesTagView was pressed
            let tagAttribute = tagDictionary[title]!
            switch tagAttribute {
            case .Generic:
                break
                //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
            case .SpecialtyButtons:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                theStackViewTagsButtons = createStackViewTagButtons()
                //need a none button, so it gives users the option to not have it.
                theStackViewTagsButtons!.addButtonToStackView(title, addNoneButton: true)
            case .SpecialtySingleSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createDistanceSliderView()
            case .SpecialtyRangeSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createAgeRangeSliderView()
            }
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //do nothing because we only act on tag Remove buttons being pressed
    }
}
