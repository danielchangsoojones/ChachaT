//
//  TagEnums.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

//enums for tags
public enum SpecialtyCategoryTitles : String {
    //using Int to seperate the specialty tag slider from tags, ect.
    case Gender = "Gender"
    case Ethnicity = "Ethnicity"
    case Sexuality = "Sexuality"
    case PoliticalGroup = "Political Group"
    case HairColor = "Hair Color"
    //single slider
    case Location = "Location"
    //range slider
    case AgeRange = "Age Range"
    
    //Purpose: I have to make a special string for what the column is named in Parse, so then I can make sure this name matches up during the query
    var parseColumnName: String {
        switch self {
        case .Gender:
            return "gender"
        case .Ethnicity:
            return "ethnicity"
        case .Sexuality:
            return "sexuality"
        case .PoliticalGroup:
            return "politicalGroup"
        case .HairColor:
            return "hairColor"
        default:
            return ""
        }
    }
    
    var specialtyTagTitles : [SpecialtyTagTitles] {
        switch self {
        case .Gender:
            return SpecialtyTagTitles.genderAllValues
        case .Ethnicity:
            return SpecialtyTagTitles.ethnicityAllValues
        case .Sexuality:
            return SpecialtyTagTitles.sexualityAllValues
        case .PoliticalGroup:
            return SpecialtyTagTitles.politicalGroupAllValues
        case .HairColor:
            return SpecialtyTagTitles.hairColorAllValues
        default:
            return []
        }
    }
    
    //Purpose: find how the drop down menu is supposed to act, based on the tag attribute
    var associatedTagAttribute : TagAttributes? {
        if SpecialtyCategoryTitles.specialtyTagMenuCategories.contains(self) {
            return .SpecialtyTagMenu
        } else if SpecialtyCategoryTitles.specialtySingleSliderCategories.contains(self) {
            return .SpecialtySingleSlider
        } else if SpecialtyCategoryTitles.specialtyRangeSliderCategories.contains(self) {
            return .SpecialtyRangeSlider
        }
        return nil
    }
    
    static let specialtyTagMenuCategories = [Gender, Ethnicity, Sexuality, PoliticalGroup, HairColor]
    static let specialtySingleSliderCategories = [Location]
    static let specialtyRangeSliderCategories = [AgeRange]
    static let allCategories = [Gender, Ethnicity, Sexuality, PoliticalGroup, HairColor, Location, AgeRange]
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
    
    var associatedSpecialtyCategoryTitle : SpecialtyCategoryTitles? {
        if SpecialtyTagTitles.genderAllValues.contains(self) {
            return .Gender
        } else if SpecialtyTagTitles.hairColorAllValues.contains(self) {
            return .HairColor
        } else if  SpecialtyTagTitles.sexualityAllValues.contains(self) {
            return .Sexuality
        } else if  SpecialtyTagTitles.politicalGroupAllValues.contains(self) {
            return .PoliticalGroup
        } else if  SpecialtyTagTitles.ethnicityAllValues.contains(self) {
            return .Ethnicity
        }
        return nil
    }
    
    //this array lets me iterate over certain sections of the enum
    static let ethnicityAllValues = [RaceBlack , RaceWhite , RaceLatino , RaceAsian , None ]
    static let hairColorAllValues = [HairColorBrunette , HairColorBlonde , HairColorRedhead , None ]
    static let genderAllValues = [GenderMale , GenderFemale , None ]
    static let sexualityAllValues = [SexualityStraight , SexualityGay , SexualityBisexual , None ]
    static let politicalGroupAllValues = [PoliticalGroupDemocrat , PoliticalGroupRepublican , None ]
    static let allValues = [RaceBlack , RaceWhite , RaceLatino , RaceAsian , HairColorBrunette , HairColorBlonde , HairColorRedhead , GenderMale , GenderFemale , SexualityStraight , SexualityGay , SexualityBisexual , PoliticalGroupRepublican , PoliticalGroupDemocrat , None ]
}

public enum TagAttributes {
    case SpecialtyTagMenu
    case SpecialtySingleSlider
    case SpecialtyRangeSlider
}

func tagTitleIsSpecial(tagTitle: String) -> Bool {
    if SpecialtyTagTitles.stringRawValue(tagTitle) != nil {
        //there is a specialtyTag associated with this title
        return true
    }
    //return nil because it was in none of the above cases, shouldn't reach this point
    return false
}


