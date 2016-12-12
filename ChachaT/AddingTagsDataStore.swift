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
    var currentUserParseTags : [ParseUserTag] = []
    
    var delegate: AddingTagsDataStoreDelegate?
    
    init(delegate: AddingTagsDataStoreDelegate) {
        super.init(superTagDelegate: delegate)
        self.delegate = delegate
        loadCurrentUserTags()
    }
    
    override init() {
        super.init()
    }
    
    func saveNewTag(title: String) {
        if findParseUserTag(title: title) == nil {
            //the current user does not already have this tag
            if let parseTag = findSearchedParseTag(title: title) {
                //the parseTag already exists in database
                saveParseUserTagFrom(parseTag: parseTag)
            } else {
                //totally new tag created
                saveNovelParseTag(title: title)
            }
        }
    }
    
    func findSearchedParseTag(title: String) -> ParseTag? {
        return ParseTag.findParseTag(title: title, parseTags: searchTags)
    }
    
    fileprivate func saveNovelParseTag(title: String) {
        let parseTag = ParseTag(title: title, attribute: .generic)
        
        parseTag.saveInBackground(block: { (success, error) in
            if success {
                self.saveParseUserTagFrom(parseTag: parseTag)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func saveParseUserTagFrom(parseTag: ParseTag) {
        let parseUserTag = ParseUserTag(parseTag: parseTag, user: User.current()!, isPending: false, approved: true)
        saveParseUserTag(parseUserTag)
    }
    
    func saveParseUserTag(_ parseUserTag: ParseUserTag) {
        User.current()!.addUniqueObject(parseUserTag.lowercasedTagTitle, forKey: "tagsArray")
        PFObject.saveAll(inBackground: [User.current()!, parseUserTag])
        currentUserParseTags.append(parseUserTag)
    }
    
    func saveSpecialtyTag(title: String, specialtyCategory: String) {
        if !checkIfGenderTag(title: title, specialtyCategory: specialtyCategory) {
            removeSpecialtyTag(specialtyCategory: specialtyCategory)
            
            //TODO: the dropDownCategories area already pulled down at this point, so we could get this parseTag without having to query the database.
            let query = ParseTag.query()!
            query.whereKey("title", equalTo: title)
            query.includeKey("dropDownCategory")
            query.getFirstObjectInBackground { (object, error) in
                if let parseTag = object as? ParseTag {
                    self.saveParseUserTagFrom(parseTag: parseTag)
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
    
    //Purpose: when gender changes we need to update the users gender in the user's column, not just the tag.
    fileprivate func checkIfGenderTag(title: String, specialtyCategory: String) -> Bool {
        if specialtyCategory == "Gender" {
            let attributePickerDataStore = AttributePickerDataStore()
            attributePickerDataStore.saveGender(gender: title)
            return true
        }
        
        return false
    }
    
    func saveCustomActionTag(databaseColumnName: String, itemToSave: Any) {
        User.current()![databaseColumnName] = itemToSave
        User.current()!.saveInBackground()
    }
}

//deleting extension
extension AddingTagsDataStore {
    //Delete Tag will only be used by generic tags because it is not possible to delete a specialty tag. If you click on a specialty tag, it just pulls drop down menu, and you can change it.
    func deleteTag(_ title: String) {
        if let parseUserTag = findParseUserTag(title: title) {
            self.deleteParseUserTag(parseUserTag: parseUserTag)
        }
    }
    
    //Purpose: remove the specialty tag from the current User's tags
    fileprivate func removeSpecialtyTag(specialtyCategory: String) {
        let parseUserTag = currentUserParseTags.first { (parseUserTag: ParseUserTag) -> Bool in
            return parseUserTag.parseTag.dropDownCategory?.name == specialtyCategory
        }
        
        if let parseUserTag = parseUserTag {
            deleteParseUserTag(parseUserTag: parseUserTag)
        }
    }
    
    fileprivate func deleteParseUserTag(parseUserTag: ParseUserTag) {
        parseUserTag.deleteInBackground()
        User.current()!.remove(parseUserTag.lowercasedTagTitle, forKey: "tagsArray")
        User.current()!.saveInBackground()
        currentUserParseTags.removeObject(parseUserTag)
    }
    
    fileprivate func findParseUserTag(title: String) -> ParseUserTag? {
        let parseUserTag = currentUserParseTags.first { (parseUserTag: ParseUserTag) -> Bool in
            return parseUserTag.lowercasedTagTitle == ParseTag.formatTitleForDatabase(title: title)
        }
        
        return parseUserTag
    }
    
}

//for loading the tags
extension AddingTagsDataStore {
    func loadCurrentUserTags() {
        let normalAndPendingTagsQuery = createInnerQuery()
        //using the not equal to false, because since not every column will have a bool (might be blank), this will just find any tag that is pending or just has nothing.
        normalAndPendingTagsQuery.whereKey("isPending", notEqualTo: false)
        
        let approvedTagsQuery = createInnerQuery()
        approvedTagsQuery.whereKey("approved", equalTo: true)
        
        let orQuery = PFQuery.orQuery(withSubqueries: [normalAndPendingTagsQuery, approvedTagsQuery])
        orQuery.includeKey("createdBy")
        orQuery.includeKey("parseTag")
        orQuery.includeKey("parseTag.dropDownCategory")
        orQuery.includeKey("parseTag.dropDownCategory.innerTags")
        
        orQuery.findObjectsInBackground { (objects, error) in
            if let parseUserTags = objects as? [ParseUserTag] {
                for parseUserTag in parseUserTags {
                    let parseTag = parseUserTag.parseTag
                    if let dropDownCategory = parseTag.dropDownCategory {
                        //a tag that is a member of the dropDownCategory
                        let innerTagTitles = dropDownCategory.innerTagTitles
                        let newDropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: innerTagTitles, dropDownAttribute: .tagChoices)
                        newDropDownTag.displayTitle = parseTag.tagTitle
                        self.tagChoicesDataArray.append(newDropDownTag)
                    } else {
                        //just a generic tag
                        let newTag = Tag(title: parseTag.tagTitle, attribute: .generic, createdBy: parseUserTag.createdBy)
                        newTag.isPending = parseUserTag.isPending
                        self.tagChoicesDataArray.append(newTag)
                    }
                    self.currentUserParseTags.append(parseUserTag)
                }
            } else if let error = error {
                print(error)
            }
            self.loadDropDownTags()
        }
    }
    
    private func createInnerQuery() -> PFQuery<PFObject> {
        let query = ParseUserTag.query()!
        query.whereKey("user", equalTo: User.current()!)
        return query
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

//Pending Tags
extension AddingTagsDataStore {
    func approveTag(title: String) {
        if let parseUserTag = findParseUserTag(title: title) {
            parseUserTag.approved = true
            parseUserTag.isPending = false
            saveParseUserTag(parseUserTag)
        }
    }
    
    func rejectTag(title: String) {
        if let parseUserTag = findParseUserTag(title: title) {
            parseUserTag.approved = false
            parseUserTag.isPending = false
            parseUserTag.saveInBackground()
        }
    }
}

//Right now, my delegate doesn't do anything, but it will probably need to do something in the future, so I didn't refactor it.
protocol AddingTagsDataStoreDelegate : TagDataStoreDelegate {
}

extension AddingTagsToProfileViewController: AddingTagsDataStoreDelegate {
}
