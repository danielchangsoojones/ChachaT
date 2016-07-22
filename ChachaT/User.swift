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
    @NSManaged var title: String?
    @NSManaged var factOne: String?
    @NSManaged var factTwo: String?
    @NSManaged var factThree: String?
    @NSManaged var location: PFGeoPoint?

    
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

