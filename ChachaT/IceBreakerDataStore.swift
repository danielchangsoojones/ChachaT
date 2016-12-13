//
//  IceBreakerDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

protocol IceBreakerDataStoreDelegate {
    func passCurrentUser(iceBreakers: [IceBreaker])
}

class IceBreakerDataStore {
    var delegate: IceBreakerDataStoreDelegate?
    
    init(delegate: IceBreakerDataStoreDelegate) {
        self.delegate = delegate
        loadIceBreakers()
    }
    
    func loadIceBreakers() {
        let query = IceBreakerParse.query()! as! PFQuery<IceBreakerParse>
        query.whereKey(IceBreakerParse.Constants.user, equalTo: User.current()!)
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { (iceBreakersParse, error) in
            var iceBreakers: [IceBreaker] = []
            if let iceBreakersParse = iceBreakersParse {
                iceBreakers = iceBreakersParse.map({ (ice: IceBreakerParse) -> IceBreaker in
                    return IceBreaker(text: ice.text, user: ice.user, iceBreakerParse: ice)
                })
            } else if let error = error {
                print(error)
            }
            self.delegate?.passCurrentUser(iceBreakers: iceBreakers)
        }
    }
}

extension IceBreakerDataStore {
    func delete(iceBreaker: IceBreaker) {
        if let ice = iceBreaker.iceBreakerParse {
            ice.deleteInBackground()
        }
    }
}
