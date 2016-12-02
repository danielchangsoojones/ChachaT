//
//  SettingsDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class SettingsDataStore {
    func saveInterestedIn(choice: String) {
        User.current()!.genderInterest = choice
        User.current()?.saveInBackground()
    }
}
