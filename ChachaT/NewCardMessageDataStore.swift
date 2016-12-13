//
//  NewCardMessageDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/16/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class NewCardMessageDataStore {
    func deleteSwipeMessage(swipe: Swipe) {
        let parseSwipe = swipe.parseSwipe
        parseSwipe?.otherUserMessage = nil
        parseSwipe?.saveInBackground()
    }
}
