//
//  AddingTagsDataModel.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

struct CustomDropDownParseColumnNames {
    static let height = "height"
    static let age = "birthDate"
}

class AddingTagsDataStore: SuperTagDataStore {
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
    var currentUserParseTags: [ParseTag] = []
    
    var delegate: AddingTagsDataStoreDelegate?
    
    init(delegate: AddingTagsDataStoreDelegate) {
        super.init(superTagDelegate: delegate)
        self.delegate = delegate
        loadCurrentUserTags()
    }
    
    //Delete Tag will only be used by generic tags because it is not possible to delete a specialty tag. If you click on a specialty tag, it just pulls drop down menu, and you can change it.
    func deleteTag(_ title: String) {
        for parseTag in currentUserParseTags where parseTag.tagTitle == title {
            let relation = User.current()!.relation(forKey: "tags")
            relation.remove(parseTag)
            User.current()!.saveInBackground()
        }
    }
    
    
    func saveNewTag(title: String) {
        let query = ParseTag.query()!
        query.whereKey("title", equalTo: title)
        
        //TODO: Technically, any tag that reaches this point would mean that no other tag exists yet, so we don't need to find the first tag in the background. Because the only way you can create a new tag is to have searched through the database already.
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
                    parseTag.tagTitle = title
                    parseTag.attribute = TagAttributes.generic.rawValue
                    parseTag.isPrivate = false
                    
                    parseTag.saveInBackground(block: { (success, error) in
                        if success {
                            let relation = User.current()!.relation(forKey: "tags")
                            relation.add(parseTag)
                            
                            User.current()?.saveInBackground()
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
                let relation = User.current()!.relation(forKey: "tags")
                relation.add(parseTag)
                
                User.current()?.saveInBackground()
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
                let relation = User.current()!.relation(forKey: "tags")
                relation.add(parseTag)
                User.current()?.saveInBackground()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func saveCustomActionTag(databaseColumnName: String, itemToSave: Any) {
        User.current()![databaseColumnName] = itemToSave
        User.current()!.saveInBackground()
    }
    
    //Purpose: remove the specialty tag from the current User's tags
    fileprivate func removeSpecialtyTag(specialtyCategory: String) {
        for parseTag in currentUserParseTags where parseTag.dropDownCategory?.name == specialtyCategory {
            //remove the previous tag that was correlated to the specific category
            let relation = User.current()!.relation(forKey: "tags")
            relation.remove(parseTag)
        }
    }
}

//for loading the tags
extension AddingTagsDataStore {
    //TODO: if nothing exists, then it will print error because the user doesn't have a tags row. Should create one when the user signs up.
    func loadCurrentUserTags() {
        let query = User.current()!.tags.query()
        query.includeKey("dropDownCategory")
        query.includeKey("dropDownCategory.innerTags")
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                for parseTag in parseTags {
                    if let dropDownCategory = parseTag.dropDownCategory {
                        //a tag that is a member of the dropDownCategory
                        let innerTagTitles = dropDownCategory.innerTagTitles
                        let newDropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: innerTagTitles, dropDownAttribute: .tagChoices)
                        newDropDownTag.displayTitle = parseTag.tagTitle
                        self.tagChoicesDataArray.append(newDropDownTag)
                    } else {
                        //just a generic tag
                        let newTag = Tag(title: parseTag.tagTitle, attribute: .generic)
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
        query.includeKey("innerTags")
        
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
                    var dropDownTag : DropDownTag?
                    switch dropDownCategory.type {
                    case DropDownAttributes.tagChoices.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: dropDownCategory.innerTagTitles, dropDownAttribute: .tagChoices)
                    case DropDownAttributes.singleSlider.rawValue, DropDownAttributes.rangeSlider.rawValue:
                        dropDownTag = self.loadCustomDropDownTags(category: dropDownCategory.type, parseColumnName: dropDownCategory.parseColumnName ?? "")
                    default:
                        break
                    }
                    if let dropDownTag = dropDownTag {
                        self.tagChoicesDataArray.append(dropDownTag)
                    }
                }
            } else if let error = error {
                print(error)
            }
            
            let sortedArray = self.tagChoicesDataArray.sorted(by: { (currentTag: Tag, nextTag: Tag) -> Bool in
                return self.sortTags(currentTag: currentTag, nextTag: nextTag)
            })
            self.delegate?.setChoicesViewTagsArray(sortedArray)
        }
    }
    
    fileprivate func sortTags(currentTag: Tag, nextTag: Tag) -> Bool {
        let isCurrentTagADropDown: Bool = currentTag is DropDownTag
        let isNextTagADropDown: Bool = nextTag is DropDownTag
        
        if isCurrentTagADropDown == isNextTagADropDown {
            //they are the same type of tag, so alphabetize them
            return currentTag.title.localizedCaseInsensitiveCompare(nextTag.title) == ComparisonResult.orderedAscending
        } else {
            //place any dropDownTags at the end of the array
            return !(currentTag is DropDownTag)
        }
    }
    
    fileprivate func loadCustomDropDownTags(category: String, parseColumnName: String) -> DropDownTag? {
        var dropDownTag: DropDownTag?
        switch parseColumnName {
            //TODO: make an init for dropDownTag that doesn't need all the extra attributes that don't matter for this page.
        case CustomDropDownParseColumnNames.height:
            //the attributes on this dropDownTag don't matter that much, we just need to initialize it. Because, we really just want the title to be set, so we can do a custom action on it.
            dropDownTag = DropDownTag(specialtyCategory: category, maxValue: 0, suffix: "", dropDownAttribute: .rangeSlider)
            dropDownTag?.title = "Height" //setting a custom title
        case CustomDropDownParseColumnNames.age:
            dropDownTag = DropDownTag(specialtyCategory: category, maxValue: 0, suffix: "", dropDownAttribute: .rangeSlider)
            dropDownTag?.title = "Age"
        default:
            break
        }
        dropDownTag?.databaseColumnName = parseColumnName
        return dropDownTag
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
