//
//  AddingTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
//This type of tagView is for when we are in the addingTagViewsToProfilePage, we want to have a special tag view that holds a search bar, so we need to do some special stuff in this class, to make it all work correctly within the TagListView.
class AddingTagView: TagView {
    private var searchBarPlaceHolderText: String = "Add Tag..."

    var searchTextField : UITextField!
    
    var delegate: AddingTagViewDelegate?
    
    init(textFieldDelegate: UITextFieldDelegate, delegate: AddingTagViewDelegate, textFont: UIFont, paddingX: CGFloat, paddingY: CGFloat, borderWidth: CGFloat, cornerRadius: CGFloat, tagBackgroundColor: UIColor) {
        super.init(frame: CGRectZero)
        self.delegate = delegate
        self.textFont = textFont
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.tagBackgroundColor = tagBackgroundColor
        addTextFieldSubview(textFieldDelegate)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Purpose: the user should be able to type into the tag to find new tags
    func addTextFieldSubview(textFieldDelegate: UITextFieldDelegate) {
        searchTextField = UITextField()
        searchTextField.autocorrectionType = .No
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        searchTextField.delegate = textFieldDelegate
        searchTextField.clearButtonMode = .Always
        self.addSubview(searchTextField)
        searchTextField.placeholder = searchBarPlaceHolderText
        searchTextField.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                //if they type and then delete all their typing, then we should resign the keyboard.
                textField.resignFirstResponder()
            } else {
                delegate?.textFieldDidChange(text)
            }
        }
    }
    
    //overriding this method because in the superclass (TagView) it is making the intrinsic content size based upon the titleLabel. Well, this tagView does not have a title. It has a search bar inside of it, so we have to make sure the intrinsicContentSize still calculates accordingly.
    override func intrinsicContentSize() -> CGSize {
        var size = searchBarPlaceHolderText.sizeWithAttributes([NSFontAttributeName: textFont])
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        return size
    }
}

protocol AddingTagViewDelegate {
    func textFieldDidChange(searchText: String)
}

extension AddingTagsToProfileViewController: AddingTagViewDelegate {
    func textFieldDidChange(searchText: String) {
        var filtered:[String] = []
        addingTagMenuView.removeAllTags()
        filtered = searchDataArray.filter({ (tagTitle) -> Bool in
            //finds the tagTitle, but if nil, then uses the specialtyTagTitle
            //TODO: have to make sure if the specialtyTagTitle is nil, then it goes the specialtyCategoryTitel
            //TODO: make the first one to show up be the best matching word, like if I search "a" then apple should be in front of "banana"
            let tmp: NSString = tagTitle
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        //we already check if the text is empty over in the AddingTagView class
        if(filtered.count == 0){
            //there is text, but it has no matches in the database
            //TODO: it should say no matches to your search, maybe be the first to join?
            view.gestureRecognizers?.removeAll()
            addingTagMenuView.createNewTagTableView(searchText)
        } else {
            //there is text, and we have a match, soa the tagChoicesView changes accordingly
            for (index, tagTitle) in filtered.enumerate() {
                let tagView = addingTagMenuView.addTag(tagTitle)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.selected = true
                }
            }
        }
    }
    
    //Purpose: find the tagView that is an AddingTagView, because we want to do special things to that one.
    func findAddingTagTagView() -> AddingTagView? {
        for tagView in tagChoicesView.tagViews where tagView is AddingTagView {
            return tagView as? AddingTagView
        }
        return nil //shouldn't reach this point
    }
}

//textField Delegate Extension for the AddingTagView textField
extension AddingTagsToProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        //TODO: hide all tagViews that aren't AddingtagView
        //this gesture recognizer fucks with the IndexRowAtPath for a tableView. So, I remove it when we get to the createNewTag TableView.
        //TODO: set this in viewDidLoad/create viewControllerExtension because this creates gesture recognizer every time the textField is started.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddingTagsToProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        createTagMenuView()
        addingTagMenuView.setDelegate(self)
    }
    
    //Calls this function when the tap is recognized.
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        addingTagMenuView.removeFromSuperview()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func createTagMenuView() {
        addingTagMenuView = AddingTagMenuView.instanceFromNib()
        self.view.addSubview(addingTagMenuView)
        addingTagMenuView.snp_makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(addingTagMenuView.superview!)
            if let addingTagView = findAddingTagTagView() {
                make.top.equalTo(addingTagView.snp_bottom)
            }
        }
    }
    
}






