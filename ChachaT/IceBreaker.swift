//
//  IceBreaker.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class IceBreaker {
    var user: User
    var text: String?
    
    var iceBreakerParse: IceBreakerParse?
    
    init(text: String? = nil, user: User = User.current()!, iceBreakerParse: IceBreakerParse? = nil) {
        self.text = text
        self.user = user
        self.iceBreakerParse = iceBreakerParse
    }
}
