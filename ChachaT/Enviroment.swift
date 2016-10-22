//
//  Enviroment.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

enum Environment: String {
    case Staging = "staging"
    case Production = "production"
    
    var applicationId: String {
        switch self {
        case .Staging: return "djflkajsdlfjienrj3457698"
        case .Production: return "shuffle12890432EJLDIFJEKhdhd"
        }
    }
    
    var server: String {
        switch self {
        case .Staging: return "https://chachatinder.herokuapp.com/parse"
        case .Production: return "http://shuffles-production.herokuapp.com/parse"
        }
    }
}
