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
    
    //TODO: if nothing exists, then it will print error because the user doesn't have a tags row. Should create one when the user signs up.
    func loadCurrentUserTags() {
        let query = Tags.query()!
        query.whereKey("createdBy", equalTo: User.current()!)
        //can use FirstObject because there really should only be one result returned anyway.
        query.getFirstObjectInBackground { (object, error) in
            if let tag = object as? Tags , error == nil {
                for tagTitle in tag.genericTags {
                    let newTag = Tag(title: tagTitle, attribute: .generic)
                    self.tagChoicesDataArray.append(newTag)
                }
                self.loadCurrentUserSpecialtyTags(tag)
            } else {
                print(error)
            }
            //this should load the tagViews even if there is error, so at least the user can see the CreationTagView
            self.delegate?.setChoicesViewTagsArray(self.tagChoicesDataArray)
        }
    }
    
    //TODO: I have to manually add every new specialty category, somehow it should be able to use the Parse names from the Tag enum, and just get all of them
    fileprivate func loadCurrentUserSpecialtyTags(_ tag: Tags) {
        //Doing an awkward mass nil check, but necessary and couldn't think of better way.
        let specialtyTagTitlesIntegers : [Int] = [tag.ethnicity, tag.hairColor, tag.gender, tag.politicalGroup, tag.sexuality]
        for rawValue in specialtyTagTitlesIntegers {
            if let specialtyTagTitle = SpecialtyTagTitles(rawValue: rawValue) {
                if let tagAttribute = specialtyTagTitle.associatedSpecialtyCategoryTitle?.associatedDropDownAttribute {
                    var dropDownTag : DropDownTag!
                    switch tagAttribute {
                    case .tagChoices:
                        let innerTagTitles : [String] = specialtyTagTitle.associatedSpecialtyCategoryTitle!.specialtyTagTitles.map {
                            $0.toString
                        }
                        dropDownTag = DropDownTag(tagTitle: specialtyTagTitle.toString,
                                                  specialtyCategory: specialtyTagTitle.associatedSpecialtyCategoryTitle!.rawValue,
                                                  innerTagTitles: innerTagTitles,
                                                  isPrivate: specialtyTagTitle.associatedSpecialtyCategoryTitle?.noneValue == specialtyTagTitle,
                                                  dropDownAttribute: .tagChoices)
                    default:
                        break
                    }
                    tagChoicesDataArray.append(dropDownTag)
                }
            }
        }
        setAnyNilSpecialtyTags()
    }
    
    //Purpose: in the database, the user might not have set something like Gender yet, so we just want to show the specialty drop down tag "Gender"
    func setAnyNilSpecialtyTags() {
        var alreadyDisplayedSpecialtyCategoryTitles: [SpecialtyCategoryTitles] = []
        for tag in tagChoicesDataArray {
            if let dropDownTag = tag as? DropDownTag {
                if let specialtyCategoryTitle = SpecialtyCategoryTitles(rawValue: dropDownTag.specialtyCategory) {
                    alreadyDisplayedSpecialtyCategoryTitles.append(specialtyCategoryTitle)
                }
            }
        }
        for specialtyCategoryTitle in SpecialtyCategoryTitles.specialtyTagMenuCategories where !alreadyDisplayedSpecialtyCategoryTitles.contains(specialtyCategoryTitle) {
            let innerTagTitles : [String] = specialtyCategoryTitle.specialtyTagTitles.map {
                $0.toString
            }
            let dropDownTag = DropDownTag(specialtyCategory: specialtyCategoryTitle.rawValue, innerTagTitles: innerTagTitles, dropDownAttribute: .tagChoices)
            tagChoicesDataArray.append(dropDownTag)
        }
    }
    
    //TODO: Doing 2 API calls to delete this tag. Plus, it has an API call for every tag deleted, should delete all at once. so it is probably best to figure out how to optimize this..
    //Delete Tag will only be used by generic tags because it is not possible to delete a specialty tag. If you click on a specialty tag, it just pulls drop down menu, and you can change it.
    func deleteTag(_ title: String) {
        let query = Tags.query()!
        query.whereKey("createdBy", equalTo: User.current()!)
        //can use FirstObject because there really should only be one result returned anyway.
        query.getFirstObjectInBackground { (object, error) in
            if let tag = object as? Tags , error == nil {
                //I could just do removeObject, which would only remove the first object found. Technically, there should be only one anyway, but this removes any occurence, so I guess if duplicates somehow got into the database. This would kind of self-clean it
                tag.removeObjects(in: [title], forKey: "genericTags")
                tag.saveInBackground()
                self.delegate?.deleteTagView(title)
            } else {
                print(error)
            }
        }
    }
    
    func setSearchDataArray() {
        var alreadyContainsTagArray: [String] = []
        let query = Tags.query()
        query!.findObjectsInBackground { (objects, error) -> Void in
            if let tags = objects as? [Tags] {
                for tag in tags {
                    for tagTitle in tag.genericTags {
                        if !alreadyContainsTagArray.contains(tagTitle) {
                            //our string array does not already contain the tag title, so we can add it to our searchable array
                            alreadyContainsTagArray.append(tagTitle)
                            let tag = Tag(title: tagTitle, attribute: .generic)
                            self.searchDataArray.append(tag)
                        }
                    }
                    self.delegate?.setSearchDataArray(self.searchDataArray)
                }
            }
        }
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
        for parseTag in currentUserParseTags where parseTag.dropDownCategory.name == specialtyCategory {
            //remove the previous tag that was correlated to the specific category
            User.current()!.tags.remove(parseTag)
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
