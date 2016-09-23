//
//  Alert.swift
//  Chacha
//
//  Created by Daniel Jones on 2/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

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
        case .success :
            alertViewResponder = alert.showSuccess(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .error :
            alertViewResponder = alert.showError(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .notice :
            alertViewResponder = alert.showNotice(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .warning :
            alertViewResponder = alert.showWarning(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .info :
            alertViewResponder = alert.showInfo(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .edit :
            alertViewResponder = alert.showEdit(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .wait :
            alertViewResponder = alert.showWait(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        }
    }
    
    func createAlert(_ title: String, subtitle: String, closeButtonTitle: String, type: SCLAlertViewStyle) {
        switch type {
        case .success :
            alertViewResponder = alert.showSuccess(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .error :
            alertViewResponder = alert.showError(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .notice :
            alertViewResponder = alert.showNotice(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .warning :
            alertViewResponder = alert.showWarning(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .info :
            alertViewResponder = alert.showInfo(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .edit :
            alertViewResponder = alert.showEdit(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        case .wait :
            alertViewResponder = alert.showWait(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle , duration: 15, colorStyle: 0xFF4C5E, colorTextButton: 0xFFFFFF)
        }
    }
    
    
    
    func addButton(_ buttonTitle: String, buttonAction: () -> Void) {
        alert.addButton(buttonTitle, action: buttonAction)
    }
    
    func closeAlert(){
        alertViewResponder.close()
    }
    
    
}
