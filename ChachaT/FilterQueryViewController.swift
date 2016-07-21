//
//  FilterQueryViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class FilterQueryViewController: FilterTagViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultTags()
        tagChoicesView.delegate = self
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//extension for working with tags
extension FilterQueryViewController {
    func setDefaultTags() {
        //TODO: add in the tags the generic tags that are saved in the Parse Tag table
        for specialtyTag in SpecialtyTags.specialtyButtonValues {
            let tagView = tagChoicesView.addTag(specialtyTag.rawValue)
            tagView.backgroundColor = UIColor.blueColor()
            currentUserTags.append(Tag(title: specialtyTag.rawValue, attribute: .SpecialtyButtons, specialtyCategoryTitle: specialtyTag))
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        for tag in currentUserTags where tag.specialtyCategoryTitle == title {
            createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: false)
        }
    }
}

extension FilterQueryViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 0.5
    }
    
    var spring: CGFloat {
        return 0.7
    }
    
    var magicViews: [UIView] {
        return [tagChoicesView]
    }
}
