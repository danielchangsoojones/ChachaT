//
//  ProgressUtilities.swift
//  EFTools
//
//  Created by Brett Keck on 7/31/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import Foundation
import MBProgressHUD

open class ProgressUtilities {
    
    fileprivate static var hud: MBProgressHUD?
    
    open class func showSpinner(_ superView: UIView) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showAdded(to: superView, animated: true)
    }
    
    open class func showSpinner(_ superView: UIView, title: String) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showAdded(to: superView, animated: true)
        hud!.labelText = title
    }
    
    open class func hideSpinner() {
        if let thisHud = hud {
            thisHud.hide(true)
        }
    }
    
    open class func getHud() -> MBProgressHUD? {
        return hud
    }
}
