//
//  User.swift
//  Chacha
//
//  Created by Daniel Jones on 2/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    
    //MARK- NSManaged properies
    @NSManaged var fullName: String?
    @NSManaged var lowercaseFullName: String?
    @NSManaged var lowercaseUsername: String?
    @NSManaged var birthDate: NSDate?
    @NSManaged var profileImage: PFFile?
    @NSManaged var gender: String?
    @NSManaged var title: String?
    @NSManaged var factOne: String?
    @NSManaged var factTwo: String?
    @NSManaged var factThree: String?
    @NSManaged var questionOne: Question?
    @NSManaged var questionTwo: Question?
    @NSManaged var questionThree: Question?
    @NSManaged var race: String?
    @NSManaged var hairColor: String?
    @NSManaged var politicalAffiliation: String?
    @NSManaged var sexuality: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var anonymous: Bool
    
    func calculateBirthDate() -> Int? {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let now = NSDate()
        if let birthDate = birthDate {
            let ageComponents = calendar.components(.Year,
                                                    fromDate: birthDate,
                                                    toDate: now,
                                                    options: [])
            return ageComponents.year
        }
        return nil
        
    }
    
}

