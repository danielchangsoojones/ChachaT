//
//  TagEnums.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

//enums for tags
public enum SpecialtyCategoryTitles : Int {
    //using Int to seperate the specialty tag slider from tags, ect.
    case Gender = 0
    case Race = 1
    case Sexuality = 2
    case PoliticalGroup = 3
    case HairColor = 4
    //single slider
    case Location = 100
    //range slider
    case AgeRange = 200
    
    //saving the enums as Ints in database to make them changeable on the frontend side, also takes up less memory space on the backend.
    var toString : String {
        switch self {
        case .Gender:
            return "Gender"
        case .Race:
            return "Race"
        case .Sexuality:
            return "Sexuality"
        case .AgeRange:
            return "Age Range"
        case .PoliticalGroup:
            return "Political Group"
        case .HairColor:
            return "Hair Color"
        case .Location:
            return "Location"
        }
    }
    
    static let specialtyTagMenuCategories = [Gender, Race, Sexuality, PoliticalGroup, HairColor]
    static let specialtySingleSliderCategories = [Location]
    static let specialtyRangeSliderCategories = [AgeRange]
    static let allCategories = [Gender, Race, Sexuality, PoliticalGroup, HairColor, Location, AgeRange]
}

public enum SpecialtyTagTitles : Int {
    
    //In case I want to add other enums, I am seperating the Int categories by 100
    case RaceBlack = 1
    case RaceWhite = 2
    case RaceLatino = 3
    case RaceAsian = 4
    case HairColorBrunette = 101
    case HairColorBlonde = 102
    case HairColorRedhead = 103
    case PoliticalGroupDemocrat = 201
    case PoliticalGroupRepublican = 202
    case GenderMale = 301
    case GenderFemale = 302
    case SexualityStraight = 401
    case SexualityGay = 402
    case SexualityBisexual = 403
    case None = 0
    
    //saving the enums as Ints in database to make them changeable on the frontend side, also takes up less memory space on the backend.
    var toString : String {
        switch self {
        case .RaceBlack:
            return "Black"
        case .RaceWhite:
            return "White"
        case .RaceLatino:
            return "Latino"
        case .RaceAsian:
            return "Asian"
        case .HairColorBrunette:
            return "Brunette"
        case .HairColorBlonde:
            return "Blonde"
        case .HairColorRedhead:
            return "Redhead"
        case .PoliticalGroupDemocrat:
            return "Democrat"
        case .PoliticalGroupRepublican:
            return "Republican"
        case .GenderMale:
            return "Male"
        case .GenderFemale:
            return "Female"
        case .SexualityStraight:
            return "Straight"
        case .SexualityGay:
            return "Gay"
        case .SexualityBisexual:
            return "Bisexual"
        case .None:
            return "None"
        }
    }
    
    static func stringRawValue(rawValue: String) -> SpecialtyTagTitles? {
        for specialtyTagTitles in allValues where specialtyTagTitles.toString == rawValue  {
            return specialtyTagTitles //found a match
        }
        return nil //none of the toStrings were equivalent to the passed string
    }
    
    //this array lets me iterate over certain sections of the enum
    static let raceAllValues = [RaceBlack , RaceWhite , RaceLatino , RaceAsian , None ]
    static let hairColorAllValues = [HairColorBrunette , HairColorBlonde , HairColorRedhead , None ]
    static let genderAllValues = [GenderMale , GenderFemale , None ]
    static let sexualityAllValues = [SexualityStraight , SexualityGay , SexualityBisexual , None ]
    static let politicalGroupAllValues = [PoliticalGroupDemocrat , PoliticalGroupRepublican , None ]
    static let allValues = [RaceBlack , RaceWhite , RaceLatino , RaceAsian , HairColorBrunette , HairColorBlonde , HairColorRedhead , GenderMale , GenderFemale , SexualityStraight , SexualityGay , SexualityBisexual , PoliticalGroupRepublican , PoliticalGroupDemocrat , None ]
}

public enum TagAttributes : Int {
    case Generic
    case SpecialtyTagMenu
    case SpecialtySingleSlider
    case SpecialtyRangeSlider
    
    //saving the enums as Ints in database to make them changeable on the frontend side, also takes up less memory space on the backend.
    var toString : String {
        switch self {
        case .Generic:
            return "Generic"
        case .SpecialtyTagMenu:
            return "SpecialtyTagMenu"
        case .SpecialtySingleSlider:
            return "SpecialtySingleSlider"
        case .SpecialtyRangeSlider:
            return "SpecialtyRangeSlider"
        }
    }
}

//helper functions for enums

//Example: I pass Race and it returns .SpecialtyTagMenu
//Example: I pass Banana and it passes back .Generic because that is just a random tag
func convertTagAttributeFromCategoryTitle(specialtyCategoryTitle: SpecialtyCategoryTitles) -> TagAttributes {
    if SpecialtyCategoryTitles.specialtyTagMenuCategories.contains(specialtyCategoryTitle) {
            return TagAttributes.SpecialtyTagMenu
        } else if SpecialtyCategoryTitles.specialtySingleSliderCategories.contains(specialtyCategoryTitle) {
            return .SpecialtySingleSlider
        } else if SpecialtyCategoryTitles.specialtyRangeSliderCategories.contains(specialtyCategoryTitle) {
            return .SpecialtyRangeSlider
        }

    return .Generic //the tag was not supposed to be a special tag
}

//Purpose: to find which specialty group we are dealing with
//For Example: It figures out whether the given string should be with Hair Color, Race, ect.
func findSpecialtyCategoryTitle(tagTitle: String) -> SpecialtyCategoryTitles? {
    if let specialtyTagTitle = SpecialtyTagTitles.stringRawValue(tagTitle) {
        if  SpecialtyTagTitles.genderAllValues.contains(specialtyTagTitle) {
            return .Gender
        } else if SpecialtyTagTitles.hairColorAllValues.contains(specialtyTagTitle) {
            return .HairColor
        } else if  SpecialtyTagTitles.sexualityAllValues.contains(specialtyTagTitle) {
            return .Sexuality
        } else if  SpecialtyTagTitles.politicalGroupAllValues.contains(specialtyTagTitle) {
            return .PoliticalGroup
        } else if  SpecialtyTagTitles.raceAllValues.contains(specialtyTagTitle) {
            return .Race
        }
    }
    //return nil because it was in none of the above cases, shouldn't reach this point
    return nil
}


