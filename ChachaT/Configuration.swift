//
//  Configuration.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

struct Configuration {
    lazy var environment: Environment = {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.range(of: "Staging") != nil {
                return Environment.Staging
            }
        }
        
        return Environment.Production
    }()
}
