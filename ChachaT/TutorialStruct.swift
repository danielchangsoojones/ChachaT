//
//  TutorialStruct.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Instructions

struct Tutorial {
    static func createBodyView(hintText: String) -> CoachMarkBodyView {
        let bodyView = CoachMarkBodyDefaultView(hintText: hintText, nextText: nil)
        bodyView.isUserInteractionEnabled = false
        return bodyView
    }
}

