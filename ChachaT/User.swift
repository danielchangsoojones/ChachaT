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
    @NSManaged var birthDate: Date?
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
    @NSManaged var tags: PFRelation<ParseTag>
    var age : Int? {
        let calendar : Calendar = Calendar.current
        let now = Date()
        if let birthDate = birthDate {
            let ageComponents = (calendar as NSCalendar).components(.year,
                                                    from: birthDate,
                                                    to: now,
                                                    options: [])
            return ageComponents.year
        }
        return nil
    }
    var firstName: String? {
        //TODO: Technically, there is no gaurantee that the first space in a user's full name would be their first name, but good enough for now. 
        if let fullName = fullName {
            let delimiter = " "
            var token = fullName.components(separatedBy: delimiter)
            return token[0]
        }
        return nil
    }
    
}

