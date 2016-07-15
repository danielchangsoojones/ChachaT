//
//  TagEnums.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

//enums for tags
//TODO: I think enum expressions could be helpful in making this simpler, but I am not sure how to do that at the moment
public enum SpecialtyTags : String {
    case Gender
    case Race
    case Sexuality
    case AgeRange = "Age Range"
    case PoliticalAffiliation = "Political Affiliation"
    case HairColor = "Hair Color"
    case Location
    static let specialtyButtonValues = [Gender, Race, Sexuality, PoliticalAffiliation, HairColor]
    static let specialtySingleSliderValues = [Location]
    static let specialtyRangeSliderValues = [AgeRange]
}

public enum FilterNames : String {
    
    case RaceBlackFilter = "Black"
    case RaceWhiteFilter = "White"
    case RaceLatinoFilter = "Latino"
    case RaceAsianFilter = "Asian"
    case HairColorBrunetteFilter = "Brunette"
    case HairColorBlondeFilter = "Blonde"
    case HairColorRedheadFilter = "Redhead"
    case PoliticalAffiliationDemocratFilter = "Democrat"
    case PoliticalAffiliationRepublicanFilter = "Republican"
    case GenderMaleFilter = "Male"
    case GenderFemaleFilter = "Female"
    case SexualityStraightFilter = "Straight"
    case SexualityGayFilter = "Gay"
    case SexualityBisexualFilter = "Bisexual"
    
    //this array lets me iterate over certain sections of the enum
    static let raceAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter]
    static let hairColorAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter]
    static let genderAllValues = [GenderMaleFilter, GenderFemaleFilter]
    static let sexualityAllValues = [SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter]
    static let politicalAffiliationAllValues = [PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
    static let allValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter, HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter, GenderMaleFilter, GenderFemaleFilter, SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter, PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
}

public enum TagAttributes : String {
    case Generic
    case SpecialtyButtons
    case SpecialtySingleSlider
    case SpecialtyRangeSlider
}

//helper functions for enums

//Purpose: Find the respective SpecialtyTag for the given string value
//For example: "Black" would produce a SpecialtyTag of Race, and would return "Race: Black"
func stringToSpecialtyTagTitle(tagTitle: String) -> String? {
    if let specialtyTag = findFilterNameCategory(tagTitle) {
        //returns something like this: "Hair Color: Brunette"
        return "\(specialtyTag.rawValue): \(tagTitle)"
    }
    //if it is not a specialty tag, then it just returns nil
    return nil
}

//Purpose: to find which specialty group we are dealing with
//For Example: It figures out whether the given string should be with Hair Color, Race, ect.
func findFilterNameCategory(tagTitle: String) -> SpecialtyTags? {
    if let filterName = FilterNames(rawValue: tagTitle) {
        //we have a specialty generic tag
        if FilterNames.genderAllValues.contains(filterName) {
            return .Gender
        } else if FilterNames.hairColorAllValues.contains(filterName) {
            return .HairColor
        } else if FilterNames.sexualityAllValues.contains(filterName) {
            return .Sexuality
        } else if FilterNames.politicalAffiliationAllValues.contains(filterName) {
            return .PoliticalAffiliation
        } else if FilterNames.raceAllValues.contains(filterName) {
            return .Race
        }
    }
    //return nil because it was in none of the above cases, shouldn't reach this point
    return nil
}


func tagHasSpecialtyAttribute(tagTitle: String) -> Bool {
    if let _ = FilterNames(rawValue: tagTitle) {
        //the given tag title is one of the special tags
        return true
    }
    //the tag is not part of the FilterNames enum, so it is not a specialty tag.
    return false
}

//removes the Specialty prefix we had created earlier, for example, it will remove "Hair Color: "
func removeSpecialtyPrefixString(tagTitle: String) -> String {
    if let indexOfColonCharacter = tagTitle.characters.indexOf(":") {
        //we are looking for colon and then advancing by two, so we pass the space. We only want to get something like "Redhead", not ": Redhead"
        let tagTitleSubstring = tagTitle.substringFromIndex(indexOfColonCharacter.advancedBy(2))
        if tagTitle.containsString(": ?") {
            //we have a specialty tag that does not have an attribute assigned to it, but we still want to have a stackview pop up when clicked, so the user can actually set it.
            return tagTitle.substringToIndex(indexOfColonCharacter)
        } else if tagHasSpecialtyAttribute(tagTitleSubstring) {
            //we have a specialty tag, so we want to return a string with only the actual attribute.
            return tagTitleSubstring
        }
    }
    //if it does none of the above, then we just want to return the given tag title back, as it is just a Generic tag
    return tagTitle
}


