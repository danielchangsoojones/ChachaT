//
//  PopulateDropDownCategories.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

//This class creates a simple way to populate the DropDownCategories in the production/development database
class PopulateDropDownCategories {
    fileprivate enum TagChoices: String {
        case Ethnicity
        case HairColor = "Hair Color"
        case Gender
        case PoliticalGroup = "Political Group"
        case Sexuality
        
        var innerTags: [String] {
            //IF YOU CHANGE ONE OF THESE TITLES, YOU HAVE TO MAKE SURE TO CHANGE THE NAME OF THAT TAG IN THE ACTAUL DATABASE. BOTH PRODUCTION AND DEVELOPMENT. REMEMBER, ALL OF THESE TAGS ARE POINTED TO BY USERS, SO YOU HAVE TO BE CAREFUL WITH THEM.
            switch self {
            case .Ethnicity:
                return ["asian", "latino", "white", "black"]
            case .HairColor:
                return ["blonde", "brunette", "redhead"]
            case .Gender:
                return ["male", "female"]
            case .PoliticalGroup:
                return ["democrat", "republican"]
            case .Sexuality:
                return ["straight", "bisexual", "gay"]
            }
        }
        
        static let allTitleValues: [String] = [TagChoices.Ethnicity.rawValue, TagChoices.HairColor.rawValue, TagChoices.Gender.rawValue, TagChoices.PoliticalGroup.rawValue, TagChoices.Sexuality.rawValue]
        static let allInnerTags = [TagChoices.Ethnicity.innerTags, TagChoices.HairColor.innerTags, TagChoices.Gender.innerTags, TagChoices.PoliticalGroup.innerTags, TagChoices.Sexuality.innerTags].flatMap { $0 }
    }
    
    fileprivate struct DropDownConstants {
        static let rangeSliderTitles: [String] = ["Height", "Age Range"]
        static let singleSliderTitles: [String] = ["Distance"]
    }
    
    init() {
        checkIfTagChoicesAlreadyExist()
    }
    
    func checkIfTagChoicesAlreadyExist() {
        let query = DropDownCategory.query()! as! PFQuery<DropDownCategory>
        let allDropDownCategories = [TagChoices.allTitleValues, DropDownConstants.singleSliderTitles, DropDownConstants.rangeSliderTitles].flatMap { $0 }
        query.findObjectsInBackground { (dropDownCategories, error) in
            if let dropDownCategories = dropDownCategories {
                let dropDownCategoryTitles: [String] = dropDownCategories.map({ (dropDownCategory: DropDownCategory) -> String in
                    return dropDownCategory.name
                })
                if allDropDownCategories.containsArray(dropDownCategoryTitles) {
                    //the database does not have any dropDownCategories that it shouldn't, but this, doesn't mean that it has all the necessary ones
                    let differenceArray: [String] = allDropDownCategories.difference(dropDownCategoryTitles)
                    if differenceArray.isEmpty {
                        //the dropDownCategory has all the necessary titles
                        print("the dropDownCategory has all the necessary titles")
                    } else {
                        //the database is missing some categories
                        self.createDropDownCategoriesInTheDatabase(tagsToCreateInDatabase: differenceArray)
                    }
                }
                
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func createDropDownCategoriesInTheDatabase(tagsToCreateInDatabase: [String]) {
        for dropDownCategoryName in tagsToCreateInDatabase {
            if TagChoices.allTitleValues.contains(dropDownCategoryName) {
                createTagChoicesInDatabase(title: dropDownCategoryName)
            } else if DropDownConstants.rangeSliderTitles.contains(dropDownCategoryName) {
                createRangeSliders(categoryName: dropDownCategoryName)
            } else if DropDownConstants.singleSliderTitles.contains(dropDownCategoryName) {
                createSingleSliders(categoryName: dropDownCategoryName)
            }
        }
    }
    
    fileprivate func createRangeSliders(categoryName: String) {
        switch categoryName {
        case "Height":
            createNewSliderCategory(name: "Height", parseColumnName: "height", min: 54, max: 84, suffix: "\"", isSingleSlider: false)
        case "Age Range":
            createNewSliderCategory(name: "Age Range", parseColumnName: "birthDate", min: 18, max: 65, suffix: "yrs", isSingleSlider: false)
        default:
            break
        }
    }
    
    fileprivate func createSingleSliders(categoryName: String) {
        switch categoryName {
        case "Distance":
            createNewSliderCategory(name: "Distance", parseColumnName: "location", min: 0, max: 50, suffix: "mi", isSingleSlider: true)
        default:
            break
        }
    }
    
    fileprivate func createNewSliderCategory(name:String, parseColumnName: String, min: Int, max: Int, suffix: String, isSingleSlider: Bool) {
        let dropDownCategory = DropDownCategory()
        dropDownCategory.name = name
        dropDownCategory.innerTags = nil
        dropDownCategory.type = isSingleSlider ? DropDownAttributes.singleSlider.rawValue : DropDownAttributes.rangeSlider.rawValue
        dropDownCategory.parseColumnName = parseColumnName
        dropDownCategory.max = max
        dropDownCategory.min = min
        dropDownCategory.suffix = suffix
        dropDownCategory.saveInBackground()
    }
    
    fileprivate func createTagChoicesInDatabase(title: String) {
        let dropDownCategory = DropDownCategory()
        dropDownCategory.type = DropDownAttributes.tagChoices.rawValue
        dropDownCategory.parseColumnName = ""
        dropDownCategory.max = -100
        dropDownCategory.min = -100
        dropDownCategory.suffix = ""
        dropDownCategory.name = title
        dropDownCategory.saveInBackground { (success, error) in
            if success {
                self.createInnerParseTags(dropDownCategory: dropDownCategory)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func createInnerParseTags(dropDownCategory: DropDownCategory) {
        let query = ParseTag.query()! as! PFQuery<ParseTag>
        let innerTagTitles: [String] = TagChoices(rawValue: dropDownCategory.name)!.innerTags
        query.whereKey("title", containedIn: innerTagTitles)
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                let alreadySavedParseTagTitles: [String] = parseTags.map({ (parseTag: ParseTag) -> String in
                    dropDownCategory.addUniqueObject(parseTag, forKey: "innerTags")
                    dropDownCategory.saveInBackground()
                    return parseTag.tagTitle
                })
                let differenceArray: [String] = innerTagTitles.difference(alreadySavedParseTagTitles)
                for tagTitle in differenceArray {
                    self.saveParseTag(tagTitle: tagTitle, dropDownCategory: dropDownCategory)
                }
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func saveParseTag(tagTitle: String, dropDownCategory: DropDownCategory) {
        let parseTag = ParseTag()
        parseTag.tagTitle = tagTitle.lowercased()
        parseTag.attribute = TagAttributes.dropDownMenu.rawValue
        parseTag.isPrivate = false
        parseTag.dropDownCategory = dropDownCategory
        parseTag.saveInBackground { (success, error) in
            if success {
                dropDownCategory.addUniqueObject(parseTag, forKey: "innerTags")
                dropDownCategory.saveInBackground()
            } else if let error = error {
                print(error)
            }
        }
    }
    
}
