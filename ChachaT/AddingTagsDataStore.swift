//
//  AddingTagsDataModel.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class AddingTagsDataStore {
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    var searchDataArray : [Tag] = [] //tags that will be available for searching
    
    var currentUserParseTags: [ParseTag] = []
    
    var delegate: AddingTagsDataStoreDelegate?
    
    init(delegate: AddingTagsDataStoreDelegate) {
        self.delegate = delegate
        loadCurrentUserTags()
        setSearchDataArray()
    }
    
    //Delete Tag will only be used by generic tags because it is not possible to delete a specialty tag. If you click on a specialty tag, it just pulls drop down menu, and you can change it.
    func deleteTag(_ title: String) {
        for parseTag in currentUserParseTags where parseTag.title == title {
            User.current()!.tags.remove(parseTag)
            User.current()!.saveInBackground()
        }
    }
    
    func setSearchDataArray() {
        //TODO: figure out how to properly set the search array when they search
    }
    
    func saveNewTag(title: String) {
        let query = ParseTag.query()!
        query.whereKey("title", equalTo: title)
        
        query.getFirstObjectInBackground { (object, error) in
            if let parseTag = object as? ParseTag {
                //add this already existing tag to the User's tags
                let relation = User.current()!.relation(forKey: "tags")
                relation.add(parseTag)

                User.current()!.saveInBackground()
            } else if let error = error {
                let errorCode = error._code
                if errorCode == PFErrorCode.errorObjectNotFound.rawValue {
                    //tag doesn't exist yet, so make a new tag, and then add it to the current User's tags
                    let parseTag = ParseTag()
                    parseTag.title = title
                    parseTag.attribute = "Generic"
                    parseTag.isPrivate = false
                    
                    parseTag.saveInBackground(block: { (success, error) in
                        if success {
                            let relation = User.current()!.relation(forKey: "tags")
                            relation.add(parseTag)
                            User.current()!.saveInBackground()
                        } else if let error = error {
                            print(error)
                        }
                    })
                } else {
                    print(error)
                }
            }
        }
    }
    
    func saveSpecialtyTag(title: String, specialtyCategory: String) {
        removeSpecialtyTag(specialtyCategory: specialtyCategory)
        
        let query = ParseTag.query()!
        query.whereKey("title", equalTo: title)
        query.getFirstObjectInBackground { (object, error) in
            if let parseTag = object as? ParseTag {
                //add the new tag chosen tag to the User's tags
                User.current()!.tags.add(parseTag)
                User.current()!.saveInBackground()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func savePrivacyTag(specialtyCategory: String) {
        removeSpecialtyTag(specialtyCategory: specialtyCategory)
    
        let query = ParseTag.query()!
        query.whereKey("isPrivate", equalTo: true)
        let innerQuery = DropDownCategory.query()!
        innerQuery.whereKey("name", equalTo: specialtyCategory)
        query.whereKey("dropDownCategory", matchesQuery: innerQuery)
        
        query.getFirstObjectInBackground { (object, error) in
            if let parseTag = object as? ParseTag {
                User.current()!.tags.add(parseTag)
                User.current()?.saveInBackground()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    //Purpose: remove the specialty tag from the current User's tags
    fileprivate func removeSpecialtyTag(specialtyCategory: String) {
        for parseTag in currentUserParseTags where parseTag.dropDownCategory?.name == specialtyCategory {
            //remove the previous tag that was correlated to the specific category
            User.current()!.tags.remove(parseTag)
        }
    }
}

//for loading the tags
extension AddingTagsDataStore {
    //TODO: if nothing exists, then it will print error because the user doesn't have a tags row. Should create one when the user signs up.
    func loadCurrentUserTags() {
        let query = User.current()!.tags.query()
        query.includeKey("dropDownCategory")
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                for parseTag in parseTags {
                    if let dropDownCategory = parseTag.dropDownCategory {
                        //a tag that is a member of the dropDownCategory
                        let innerTagTitles = dropDownCategory.innerTagTitles ?? []
                        let newDropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: innerTagTitles, dropDownAttribute: .tagChoices)
                        newDropDownTag.displayName = parseTag.title
                        self.tagChoicesDataArray.append(newDropDownTag)
                    } else {
                        //just a generic tag
                        let newTag = Tag(title: parseTag.title, attribute: .generic)
                        self.tagChoicesDataArray.append(newTag)
                    }
                    self.currentUserParseTags.append(parseTag)
                }
            } else if let error = error {
                print(error)
            }
            self.loadDropDownTags()
        }
    }
    
    func loadDropDownTags() {
        let query = DropDownCategory.query() as! PFQuery<DropDownCategory>
        query.whereKey("type", equalTo: DropDownAttributes.tagChoices.rawValue) //we only need tagChoices for the adding tags page, no sliders necessary
        
        //we don't need to set the dropDownTags for tags that the user has already set. For example, if the user set the Gender Category to male, then we will show Male for the dropDownCategory
        let alreadySetDropDownCategories: [String] = tagChoicesDataArray.filter { (tag: Tag) -> Bool in
            return tag is DropDownTag
        }.map { (tag: Tag) -> String in
            let dropDownTag = tag as! DropDownTag
            return dropDownTag.specialtyCategory
        }
        query.whereKey("name", notContainedIn: alreadySetDropDownCategories)
        
        query.findObjectsInBackground { (categories, error) in
            if let categories = categories {
                for dropDownCategory in categories {
                    var dropDownTag : DropDownTag!
                    switch dropDownCategory.type {
                    case DropDownAttributes.tagChoices.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: dropDownCategory.innerTagTitles ?? [], dropDownAttribute: .tagChoices)
                    default:
                        break
                    }
                    self.tagChoicesDataArray.append(dropDownTag)
                }
            } else if let error = error {
                print(error)
            }
            //this should load the dropDownTagViews even if there is error.
            self.delegate?.setChoicesViewTagsArray(self.tagChoicesDataArray)
        }
    }
}

protocol AddingTagsDataStoreDelegate : TagDataStoreDelegate {
    func deleteTagView(_ title: String)
}

extension AddingTagsToProfileViewController: AddingTagsDataStoreDelegate {
    func deleteTagView(_ title: String) {
        tagChoicesView.removeTag(title)
    }
}
