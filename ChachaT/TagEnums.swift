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
    case Location = "Distance"
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
        case .Location:
            return "location"
        case .AgeRange:
            return "birthDate"
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
    
    var sliderComponents: (min: Int, max: Int, suffix: String)? {
        switch self {
        case .Location:
            return (0, 50, "mi")
        case .AgeRange:
            return (18, 65, "yrs")
        default:
            return nil
        }
    }
    
    //Purpose: if we have a suffix from a sliderView, this allows us to find out what specialtyCategory it is attached to.
    static func suffixRawValue(suffix: String) -> SpecialtyCategoryTitles? {
        for specialtyCategory in allCategories where specialtyCategory.sliderComponents?.suffix == suffix {
            if let sliderComponents = specialtyCategory.sliderComponents, sliderComponents.suffix == suffix {
                return specialtyCategory
            }
        }
        return nil
    }
    
    var associatedDropDownAttribute : DropDownAttributes? {
        if SpecialtyCategoryTitles.specialtyTagMenuCategories.contains(self) {
            return .tagChoices
        } else if SpecialtyCategoryTitles.specialtySingleSliderCategories.contains(self) {
            return .singleSlider
        } else if SpecialtyCategoryTitles.specialtyRangeSliderCategories.contains(self) {
            return .rangeSlider
        }
        return nil
    }
    
    //TODO: there is probably a much smarter/more effecient/less manual way to do this. Just can't figure it out right now...
    var noneValue : SpecialtyTagTitles? {
        switch self {
        case .Gender:
            return .genderNone
        case .Ethnicity:
            return .raceNone
        case .Sexuality:
            return .sexualityNone
        case .PoliticalGroup:
            return .politicalGroupNone
        case .HairColor:
            return .hairColorNone
        default:
            return nil
        }
    }
    
    static let specialtyTagMenuCategories = [Gender, Ethnicity, Sexuality, PoliticalGroup, HairColor]
    static let specialtySingleSliderCategories = [Location]
    static let specialtyRangeSliderCategories = [AgeRange]
    static let allCategories = [specialtyTagMenuCategories, specialtySingleSliderCategories, specialtyRangeSliderCategories].joined()
}

//TODO: make a rawValue for private because if a user has not inputed a tag, then we want to put an exclamation point, but if they have just marked it as private, then we want to show it as private. 
public enum SpecialtyTagTitles : Int {
    
    //In case I want to add other enums, I am seperating the Int categories by 100
    case raceNone = -1
    case racePrivate = -2
    case raceBlack = 1
    case raceWhite = 2
    case raceLatino = 3
    case raceAsian = 4
    case hairColorNone = -101
    case hairColorPrivate = -102
    case hairColorBrunette = 101
    case hairColorBlonde = 102
    case hairColorRedhead = 103
    case politicalGroupNone = -201
    case politicalGroupPrivate = -202
    case politicalGroupDemocrat = 201
    case politicalGroupRepublican = 202
    case genderNone = -301
    case genderPrivate = -302
    case genderMale = 301
    case genderFemale = 302
    case sexualityNone = -401
    case sexualityPrivate = -402
    case sexualityStraight = 401
    case sexualityGay = 402
    case sexualityBisexual = 403
    
    //saving the enums as Ints in database to make them changeable on the frontend side, also takes up less memory space on the backend.
    var toString : String {
        switch self {
        case .raceBlack:
            return "Black"
        case .raceWhite:
            return "White"
        case .raceLatino:
            return "Latino"
        case .raceAsian:
            return "Asian"
        case .hairColorBrunette:
            return "Brunette"
        case .hairColorBlonde:
            return "Blonde"
        case .hairColorRedhead:
            return "Redhead"
        case .politicalGroupDemocrat:
            return "Democrat"
        case .politicalGroupRepublican:
            return "Republican"
        case .genderMale:
            return "Male"
        case .genderFemale:
            return "Female"
        case .sexualityStraight:
            return "Straight"
        case .sexualityGay:
            return "Gay"
        case .sexualityBisexual:
            return "Bisexual"
        case .raceNone, .hairColorNone, .politicalGroupNone, .genderNone, .sexualityNone:
            return "None"
        case .racePrivate, .hairColorPrivate, .politicalGroupPrivate, .genderPrivate, .sexualityPrivate:
            return "Private"
        }
    }
    
    static func stringRawValue(_ rawValue: String) -> SpecialtyTagTitles? {
        for specialtyTagTitles in allValues where specialtyTagTitles.toString == rawValue  {
            return specialtyTagTitles //found a match
        }
        return nil //none of the toStrings were equivalent to the passed string
    }
    
    var associatedSpecialtyCategoryTitle : SpecialtyCategoryTitles? {
        if SpecialtyTagTitles.genderAllValues.contains(self) || self == .genderNone {
            return .Gender
        } else if SpecialtyTagTitles.hairColorAllValues.contains(self) || self == .hairColorNone {
            return .HairColor
        } else if  SpecialtyTagTitles.sexualityAllValues.contains(self) || self == .sexualityNone {
            return .Sexuality
        } else if  SpecialtyTagTitles.politicalGroupAllValues.contains(self) || self == .politicalGroupNone {
            return .PoliticalGroup
        } else if  SpecialtyTagTitles.ethnicityAllValues.contains(self) || self == .raceNone {
            return .Ethnicity
        }
        return nil
    }
    
    //this array lets me iterate over certain sections of the enum
    static let ethnicityAllValues = [raceBlack , raceWhite , raceLatino , raceAsian]
    static let hairColorAllValues = [hairColorBrunette , hairColorBlonde , hairColorRedhead ]
    static let genderAllValues = [genderMale , genderFemale ]
    static let sexualityAllValues = [sexualityStraight , sexualityGay , sexualityBisexual ]
    static let politicalGroupAllValues = [politicalGroupDemocrat , politicalGroupRepublican ]
    static let allValues = [politicalGroupAllValues, ethnicityAllValues, hairColorAllValues, genderAllValues, sexualityAllValues].joined()
}

func tagTitleIsSpecial(_ tagTitle: String) -> Bool {
    if SpecialtyTagTitles.stringRawValue(tagTitle) != nil {
        //there is a specialtyTag associated with this title
        return true
    }
    //return nil because it was in none of the above cases, shouldn't reach this point
    return false
}


