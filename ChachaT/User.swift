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
    @NSManaged var profileImage2: PFFile?
    @NSManaged var profileImage3: PFFile?
    @NSManaged var profileImage4: PFFile?
    @NSManaged var profileImage5: PFFile?
    @NSManaged var profileImage6: PFFile?
    @NSManaged var title: String?
    @NSManaged var bulletPoint1: String?
    @NSManaged var bulletPoint2: String?
    @NSManaged var bulletPoint3: String?
    @NSManaged var facebookId : String?
    @NSManaged var location: PFGeoPoint
    var age : Int? {
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

