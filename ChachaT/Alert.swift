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
    
    let alert = SCLAlertView()
    var alertViewResponder : SCLAlertViewResponder
    
    init() {
        alertViewResponder = SCLAlertViewResponder(alertview: alert)
    }
    
    init(title: String, subtitle: String, closeButtonTitle: String, type: SCLAlertViewStyle) {
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
        if closeButtonHidden {
//            alert.showCloseButton = false
            //not working for some reason
        }
        
        alert.addButton(buttonTitle, action: buttonAction)
    }
    
    func closeAlert(){
        alertViewResponder.close()
    }
    
    
}
