//
//  NewIceBreakerDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class NewIceBreakerDataStore {
    func save(iceBreaker: IceBreaker) {
        if let newText = iceBreaker.text {
            var iceBreakerParse: IceBreakerParse!
            if let updatedIce = iceBreaker.iceBreakerParse {
                updatedIce.text = newText
                iceBreakerParse = updatedIce
            } else {
                //new iceBreakerParse
                let newIce = IceBreakerParse(text: newText)
                iceBreakerParse = newIce
            }
            iceBreakerParse.saveInBackground()
        }
    }
}
