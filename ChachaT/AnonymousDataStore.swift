//
//  AnonymousDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class AnonymousDataStore {
    var isUserAnonymous: Bool = false
    
    init() {
        //check if the user is anonymous
        self.isUserAnonymous = PFAnonymousUtils.isLinked(with: User.current())
        if isUserAnonymous {
            setAnonymousUserObjectId()
        }
    }
    
    func enableAutomaticUser() {
        User.enableAutomaticUser()
    }
    
    func saveAnonymousUser() {
        User.current()?.saveInBackground()
    }
    
    fileprivate func setAnonymousUserObjectId() {
        //by saving the user into Parse, it sets an objectId for the user after the first save. Otherwise, the user has no objectID until first saved, and there are areas within the app where the objectId is force-casted. Potentially, this could not be fast enough if the user doesn't save faster than they click a certain button, but for now, it is fine. But, honestly, I should just create a totally random objectId. It doesn't really matter, as long as we don't have one that is nil.
        User.current()?.saveInBackground()
    }
}
