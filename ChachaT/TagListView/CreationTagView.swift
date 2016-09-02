//
//  CreationTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
//This type of tagView is for when we are in the addingTagViewsToProfilePage, we want to have a special tag view that holds a search bar, so we need to do some special stuff in this class, to make it all work correctly within the TagListView.
class CreationTagView: TagView {
    private var searchBarPlaceHolderText: String = "Add Tag..."

    var searchTextField : UITextField!
    
    var delegate: CreationTagViewDelegate?
    
    init(textFieldDelegate: UITextFieldDelegate, delegate: CreationTagViewDelegate, textFont: UIFont, paddingX: CGFloat, paddingY: CGFloat, borderWidth: CGFloat, cornerRadius: CGFloat, tagBackgroundColor: UIColor) {
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

protocol CreationTagViewDelegate {
    func textFieldDidChange(searchText: String)
}

extension AddingTagsToProfileViewController: CreationTagViewDelegate {
    func textFieldDidChange(searchText: String) {
        var filtered:[String] = []
        creationMenuView.removeAllTags()
        filtered = searchDataArray.filter({ (tagTitle) -> Bool in
            //TODO: make the first one to show up be the best matching word, like if I search "a" then apple should be in front of "banana"
            let tmp: NSString = tagTitle
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        //we already check if the text is empty over in the CreationTagView class
        if filtered.isEmpty {
            //there is text, but it has no matches in the database
            creationMenuView.toggleMenuType(.Table, newTagTitle: searchText, tagTitles: nil)
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            creationMenuView.toggleMenuType(.Tags, newTagTitle: nil, tagTitles: filtered)
        }
    }
    
    //TODO: could probably be a better way to get CreationTagView because this just finds the first instance, and there only happens to be one instance. But, if we ever wanted two for some reason, then this would break.
    //Purpose: find the tagView that is an CreationTagView, because we want to do special things to that one.
    func findCreationTagView() -> CreationTagView? {
        for tagView in tagChoicesView.tagViews where tagView is CreationTagView {
            return tagView as? CreationTagView
        }
        return nil //shouldn't reach this point
    }
}

//textField Delegate Extension for the CreationTagView textField
extension AddingTagsToProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        //TODO: hide all tagViews that aren't the CreationTagView, meaning clear the screen.
        creationMenuView?.hidden = false
    }
    
    //Calls this function when the tap is recognized anywhere on the screen that is not a tappable object.
    func dismissTheKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        creationMenuView?.hidden = true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        //creating the creationMenuView here because we only want it to be visible above the keyboard, so they can scroll through all available tags.
        //But, we can only get the keyboard height through this notification.
        //IF THE CREATIONMENUVIEW IS CRASHING ON MAC SIMULATOR, TOGGLE THE KEYBOARD ON THE SIMULATOR, IT WILL CRASH WHEN THE SIMULATOR ISN'T SHOWING BECAUSE FUNCTION KEYBOARDWILLSHOW IS NEVER CALLED. BUT, SHOULD WORK WHEN KEYBOARD IS SHOWN.
        createTagMenuView(keyboardHeight)
    }
    
    func createTagMenuView(keyboardHeight: CGFloat) {
        if creationMenuView == nil {
            creationMenuView = CreationMenuView.instanceFromNib(self)
        }
        self.view.addSubview(creationMenuView)
        //TODO: I don't know why, but by setting the hidden value on the tagMenuView when I want it to disappear, it makes the height constraint = 0, so I need to remake the constraints to make the CreationMenu show up a second time. This fixes it. But, might be a better way, where I don't have to set constraints every time the keyboard appears.
        creationMenuView.snp_remakeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(keyboardHeight)
            if let addingTagView = findCreationTagView() {
                make.top.equalTo(addingTagView.snp_bottom)
            }
        }
    }
}






