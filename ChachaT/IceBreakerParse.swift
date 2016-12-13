//
//  IceBreakerParse.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class IceBreakerParse: PFObject, PFSubclassing {
    struct Constants {
        static let user = "user"
        static let text = "text"
    }
    
    
    class func parseClassName() -> String {
        return "IceBreakerParse"
    }
    
    @NSManaged var text: String
    @NSManaged var user: User
    
    override init() {
        super.init()
    }
    
    init(text: String) {
        super.init()
        self.text = text
        self.user = User.current()!
    }
}
