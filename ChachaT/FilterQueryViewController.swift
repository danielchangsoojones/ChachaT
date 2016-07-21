//
//  FilterQueryViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class FilterQueryViewController: FilterTagViewController {

    @IBAction func searchButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        //adding in generic tags
        let query = Tag.query()
        query?.whereKey("attribute", equalTo: TagAttributes.Generic.rawValue)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            for tag in objects as! [Tag] {
                self.currentUserTags.append(tag)
                self.tagChoicesView.addTag(tag.title)
            }
        })
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        for tag in currentUserTags where tag.specialtyCategoryTitle == title {
            createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: false)
        }
        for tag in currentUserTags where tag.attribute == TagAttributes.Generic.rawValue && tag.title == title {
            let tagView = tagChosenView.addTag(tag.title)
            tagChoicesView.removeTag(tag.title)
            changeTagListViewWidth(tagView, extend: true)
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
