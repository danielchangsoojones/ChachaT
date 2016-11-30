//
//  CreationMenuView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String)
}

//This is the menu that appears when you start typing in the CreationTagView. It shows all the available tags in the database, and if none exist, then it shows you how to create a new one.
class CreationMenuView: UIView {
    
    @IBOutlet weak var choicesTagListView: ChachaChoicesTagListView!
    
    var delegate: AddingTagMenuDelegate?
    
    //TODO: make the tagView only go as tall as the keyboard height because the keyboard is blocking the last few tags. Or give the scroll view some extra spacing to fix this.
    override func awakeFromNib() {
        choicesTagListView.delegate = self
    }
    
    func reset() {
        removeAllTags()
    }
    
    func removeAllTags() {
        choicesTagListView.removeAllTags()
    }
    
    class func instanceFromNib(_ delegate: AddingTagMenuDelegate) -> CreationMenuView {
        // the nibName has to match your class file and your xib file
        let nib = UINib(nibName: "CreationMenuView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CreationMenuView
        nib.delegate = delegate
        return nib
    }
    
    override var intrinsicContentSize: CGSize {
        //Superviews calculate the height of the creationMenuView based upon the intrinsicContentSize of this menu. So, we need to set the intrinsicContentHeight here, in order to allow scrollViews to calculate off of this. 
        let heightOfCreationMenuView: Double = 200
        return CGSize(width: 500, height: heightOfCreationMenuView)
    }
}

extension CreationMenuView {
    enum MenuType {
        case existingTags
        case newTag
    }
    
    func toggleMenuType(_ menuType: MenuType, newTagTitle: String?, tagTitles: [String]?) {
        switch menuType {
            case .existingTags:
                addTagsToTagListView(tagTitles)
            case .newTag:
                //Right now, I am just adding a newTag into the tagListView. So technically, the differentiation between existingTags, and newTag shouldn't matter. But, eventually, Daniel Jones wants to do some special stuff when a new tag comes up, just haven't figured out what that will be. 
                if let newTagTitle = newTagTitle {
                    addTagsToTagListView([newTagTitle])
                }
        }
    }
    
    fileprivate func addTagsToTagListView(_ tagTitles: [String]?) {
        if let tagTitles = tagTitles {
            for (index, tagTitle) in tagTitles.enumerated() {
                let tagView = choicesTagListView.addTag(tagTitle)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.isSelected = true
                }
            }
        }
    }
}

extension CreationMenuView: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        delegate?.addNewTagToTagChoiceView(title: title)
        reset()
    }
}
