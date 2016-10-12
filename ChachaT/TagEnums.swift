//
//  TagEnums.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

class holder {
    init() {
        //I am just having a holder because we need to deploy this data to the production database eventually
        //This stuff should go into a unit test
        DropDownCategory().createNewSliderCategory(name: "Distance", parseColumnName: "location", min: 0, max: 50, suffix: "mi", isSingleSlider: true)
        DropDownCategory().createNewSliderCategory(name: "Age Range", parseColumnName: "birthDate", min: 18, max: 65, suffix: "yrs", isSingleSlider: false)
    }
}


