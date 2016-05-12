//
//  ProgressUtilities.swift
//  EFTools
//
//  Created by Brett Keck on 7/31/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import Foundation
import MBProgressHUD

public class ProgressUtilities {
    
    private static var hud : MBProgressHUD?
    
    public class func showSpinner(superView : UIView) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showHUDAddedTo(superView, animated: true)
    }
    
    public class func showSpinner(superView : UIView, title : String) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showHUDAddedTo(superView, animated: true)
        hud!.labelText = title
    }
    
    public class func hideSpinner() {
        if let thisHud = hud {
            thisHud.hide(true)
        }
    }
    
    public class func getHud() -> MBProgressHUD? {
        return hud
    }
}