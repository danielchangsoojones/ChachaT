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


