//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@objc public protocol TagListViewDelegate {
    optional func tagPressed(title: String, tagView: TagView, sender: TagListView) -> Void
    optional func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) -> Void
    optional func specialtyTagPressed(title: String, tagView: SpecialtyTagView, sender: TagListView) -> Void
}

@IBDesignable
public class TagListView: UIView {
    
    @IBInspectable public dynamic var textColor: UIColor = UIColor.whiteColor() {
        didSet {
            for tagView in tagViews {
                tagView.textColor = textColor
            }
        }
    }
    
    @IBInspectable public dynamic var selectedTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            for tagView in tagViews {
                tagView.selectedTextColor = selectedTextColor
            }
        }
    }
    
    @IBInspectable public dynamic var tagBackgroundColor: UIColor = UIColor.grayColor() {
        didSet {
            for tagView in tagViews {
                tagView.tagBackgroundColor = tagBackgroundColor
            }
        }
    }
    
    @IBInspectable public dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }
    
    @IBInspectable public dynamic var tagSelectedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBackgroundColor = tagSelectedBackgroundColor
            }
        }
    }
    
    @IBInspectable public dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.cornerRadius = cornerRadius
            }
        }
    }
    @IBInspectable public dynamic var borderWidth: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.borderWidth = borderWidth
            }
        }
    }
    
    @IBInspectable public dynamic var borderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.borderColor = borderColor
            }
        }
    }
    
    @IBInspectable public dynamic var selectedBorderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBorderColor = selectedBorderColor
            }
        }
    }
    
    @IBInspectable public dynamic var paddingY: CGFloat = 2 {
        didSet {
            for tagView in tagViews {
                tagView.paddingY = paddingY
            }
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var paddingX: CGFloat = 5 {
        didSet {
            for tagView in tagViews {
                tagView.paddingX = paddingX
            }
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var marginY: CGFloat = 2 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var marginX: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    
    @objc public enum Alignment: Int {
        case Left
        case Center
        case Right
    }
    @IBInspectable public var alignment: Alignment = .Left {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var shadowColor: UIColor = UIColor.whiteColor() {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var shadowOffset: CGSize = CGSizeZero {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var shadowOpacity: Float = 0 {
        didSet {
            rearrangeViews()
        }
    }
    
    @IBInspectable public dynamic var enableRemoveButton: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.enableRemoveButton = enableRemoveButton
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable public dynamic var removeButtonIconSize: CGFloat = 12 {
        didSet {
            for tagView in tagViews {
                tagView.removeButtonIconSize = removeButtonIconSize
            }
            rearrangeViews()
        }
    }
    @IBInspectable public dynamic var removeIconLineWidth: CGFloat = 1 {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineWidth = removeIconLineWidth
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable public dynamic var removeIconLineColor: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.54) {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineColor = removeIconLineColor
            }
            rearrangeViews()
        }
    }
    
    public dynamic var textFont: UIFont = UIFont.systemFontOfSize(12) {
        didSet {
            for tagView in tagViews {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    @IBOutlet public weak var delegate: TagListViewDelegate?
    
    public private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    var shouldRearrangeViews = true
    
    // MARK: - Interface Builder
    
    public override func prepareForInterfaceBuilder() {
        addTag("Welcome")
        addTag("to")
        addTag("TagListView").selected = true
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //we want to rearrange the views for the majority of the times, but when the pop down occurs, we want to set ths shouldRearrangeViews to false, so then it doesn't update constraints and rearrange views
        //we just want the whole thing to move downward, we don't want the extra movement of tags.
        if shouldRearrangeViews {
            rearrangeViews()
        }
    }
    
    private func rearrangeViews() {
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        rowViews.removeAll(keepCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagViews.enumerate() {
            tagView.frame.size = tagView.intrinsicContentSize()
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
            }
            
            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.CGColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).CGPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .Left:
                currentRowView.frame.origin.x = 0
            case .Center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .Right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    public override func intrinsicContentSize() -> CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSizeMake(frame.width, height)
    }
    
    public func addTag(title: String) -> TagView {
        let tagView = TagView(title: title)
        
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        tagView.addTarget(self, action: #selector(tagPressed(_:)), forControlEvents: .TouchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        // Deselect all tags except this one
        tagView.onLongPress = { this in
            for tag in self.tagViews {
                tag.selected = (tag == this)
            }
        }
        return addTagView(tagView)
    }
    
    public func addTagView(tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }
    
    public func removeTag(title: String) {
        // loop the array in reversed order to remove items during loop
        for index in (tagViews.count - 1).stride(through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == title {
                removeTagView(tagView)
            }
        }
    }
    
    public func removeTagView(tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.indexOf(tagView) {
            tagViews.removeAtIndex(index)
            tagBackgroundViews.removeAtIndex(index)
        }
        
        rearrangeViews()
    }
    
    public func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }

    public func selectedTags() -> [TagView] {
        return tagViews.filter() { $0.selected == true }
    }
    
    // MARK: - Events
    
    func tagPressed(sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    func removeButtonPressed(closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}

extension TagListView {
    //Daniel Jones added this method in. It was not originally part of tagListView
    public func addSpecialtyTag(specialtyTagTitle: SpecialtyTagTitles, specialtyCategoryTitle: SpecialtyCategoryTitles) -> TagView {
        let tagView = SpecialtyTagView(tagTitle: specialtyTagTitle, specialtyTagTitle: specialtyCategoryTitle)
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        tagView.addTarget(self, action: #selector(specialtyTagPressed(_:)), forControlEvents: .TouchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        //when I was using the real tag border, it was going above the corner annotation because the border is drawn after all subviews are added.
        //So, I had to make the borderWidth = 0 and borderColor = nil, getting rid of actual border
        //I couldn't change the borderWidth/borderColor in the actual specialtyTagView class because, for some reason, they were not initialized yet.
        //So, then I create this border view, that looks like all the other borders, but is actually its own view, and this fake border does not cover the corner annotation.
        tagView.borderColor = nil
        tagView.borderWidth = 0
        
        //had to add this because I was trying to let annotation corner view appear, and it wasn't
        //I tried putting this same code in the specialtyTagView class, but it was still masking the view, until I put it here.
        tagView.clipsToBounds = false
        
        // Deselect all tags except this one
        tagView.onLongPress = { this in
            for tag in self.tagViews {
                tag.selected = (tag == this)
            }
        }
        return addTagView(tagView)
    }
    
    func specialtyTagPressed(sender: SpecialtyTagView!) {
        sender.onTap?(sender)
        delegate?.specialtyTagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    //TODO: probably should be checking something about category name also.
//    func findTagView(tagTitle: String, categoryName: String?) -> TagView? {
//        for tagView in tagViews {
//            if let categoryName = categoryName {
//                //dealing with specialty tag because it has a category name
//                let specialtyTagView = tagView as! SpecialtyTagView
//                if specialtyTagView.titleLabel!.text == tagTitle && specialtyTagView.specialtyTagTitle == categoryName {
//                    //checking if tagview is matching in tagTitle and specialtyTagTitle, because then we have found exact match
//                    return specialtyTagView
//                }
//            } else {
//                //dealing with normal generic tag
//                if tagView.titleLabel?.text == tagTitle && !(tagView is SpecialtyTagView) {
//                    //making sure we have title match and that we don't have the same title as a specialty tag view because it makes sure no specialty tag views get here
//                    return tagView
//                }
//            }
//        }
//        //if the tag view does not exist in the array
//        return nil
//    }
    
    func tagExistsInTagListView(title: String) -> Bool {
        for tagView in tagViews {
            if tagView.titleLabel?.text == title {
                return true
            }
        }
        return false
    }
}


