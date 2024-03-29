//
//  CreationTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol CreationTagViewDelegate: UITextFieldDelegate {
    func textFieldDidChange(_ searchText: String)
}

//This type of tagView is for when we are in the addingTagViewsToProfilePage, we want to have a special tag view that holds a search bar, so we need to do some special stuff in this class, to make it all work correctly within the TagListView.
class CreationTagView: TagView {
    fileprivate var searchBarPlaceHolderText: String = "Add Tag..."

    var searchTextField : UITextField!
    
    var delegate: CreationTagViewDelegate?
    
    init(textFont: UIFont, paddingX: CGFloat, paddingY: CGFloat, borderWidth: CGFloat, cornerRadius: CGFloat, tagBackgroundColor: UIColor) {
        super.init(frame: CGRect.zero)
        self.textFont = textFont
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.tagBackgroundColor = tagBackgroundColor
        self.borderColor = UIColor.black
        addTextFieldSubview()
    }
    
    func setDelegate(delegate: CreationTagViewDelegate) {
        self.delegate = delegate
        searchTextField.delegate = delegate
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Purpose: the user should be able to type into the tag to find new tags
    func addTextFieldSubview() {
        searchTextField = UITextField()
        searchTextField.autocorrectionType = .no
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        searchTextField.clearButtonMode = .always
        searchTextField.autocapitalizationType = .none
        self.addSubview(searchTextField)
        searchTextField.placeholder = searchBarPlaceHolderText
        searchTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 10, 0, 0))
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
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
    override var intrinsicContentSize : CGSize {
        var size = searchBarPlaceHolderText.size(attributes: [NSFontAttributeName: textFont])
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        return size
    }
}






