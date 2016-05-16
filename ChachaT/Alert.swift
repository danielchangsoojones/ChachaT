//
//  Alert.swift
//  Chacha
//
//  Created by Daniel Jones on 2/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import SCLAlertView

class Alert {
    
    let alert : SCLAlertView
    var alertViewResponder : SCLAlertViewResponder
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    
    init(closeButtonHidden: Bool) {
        //this is for making alerts that have a hidden close button.
        if closeButtonHidden {
            alert = SCLAlertView(appearance: appearance)
        } else {
             alert = SCLAlertView()
        }

        alertViewResponder = SCLAlertViewResponder(alertview: alert)
    }
    
    init(title: String, subtitle: String, closeButtonTitle: String, closeButtonHidden: Bool, type: SCLAlertViewStyle) {
        if closeButtonHidden {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            alert = SCLAlertView(appearance: appearance)
        } else {
            alert = SCLAlertView()
        }
        
        alertViewResponder = SCLAlertViewResponder(alertview: alert)
        switch type {
        case .Success :
            alertViewResponder = alert.showSuccess(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Error :
            alertViewResponder = alert.showError(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Notice :
            alertViewResponder = alert.showNotice(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Warning :
            alertViewResponder = alert.showWarning(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Info :
            alertViewResponder = alert.showInfo(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Edit :
            alertViewResponder = alert.showEdit(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Wait :
            alertViewResponder = alert.showWait(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        }
    }
    
    func createAlert(title: String, subtitle: String, closeButtonTitle: String, type: SCLAlertViewStyle) {
        switch type {
        case .Success :
            alertViewResponder = alert.showSuccess(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Error :
            alertViewResponder = alert.showError(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Notice :
            alertViewResponder = alert.showNotice(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Warning :
            alertViewResponder = alert.showWarning(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Info :
            alertViewResponder = alert.showInfo(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Edit :
            alertViewResponder = alert.showEdit(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .Wait :
            alertViewResponder = alert.showWait(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        }
    }
    
    
    
    func addButton(buttonTitle: String, closeButtonHidden: Bool, buttonAction: () -> Void) {
        alert.addButton(buttonTitle, action: buttonAction)
    }
    
    func closeAlert(){
        alertViewResponder.close()
    }
    
    
}
