//
//  SettingsViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Former

class SettingsViewController: FormViewController {
    
    var datastore: SettingsDataStore = SettingsDataStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        addYourStackSection()
        addLastSection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createHeader(title: String) -> LabelViewFormer<FormLabelHeaderView> {
        let header = LabelViewFormer<FormLabelHeaderView>()
        header.text = title
        return header
    }
    
    
}

//Your Stack extension
extension SettingsViewController {
    func addYourStackSection() {
        let header = createHeader(title: "Your Stack")
        let interestedInRow = createInterestedInRow()
        let section = SectionFormer(rowFormer: interestedInRow).set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
    
    private func createInterestedInRow() -> InlinePickerRowFormer<FormInlinePickerCell, String> {
        var choices: [String] = ["all", "female", "male"]
        if let index = choices.index(of: User.current()!.interestedIn ?? "") {
            //placing the previously chosen attribute first, so then the title will show that attribute, and it will also be the top choice.
            choices.remove(at: index)
            choices.insertAsFirst(User.current()!.interestedIn ?? "")
        }
        
        let row = InlinePickerRowFormer<FormInlinePickerCell, String> {
            $0.titleLabel.text = "Interested In"
        }.configure { (row) in
            row.pickerItems = choices.map({ (str: String) -> InlinePickerItem<String> in
                return InlinePickerItem(title: str)
            })
        }.onValueChanged { (item) in
            //TODO: technically, we should be saving this once the user leaves the screen. Right now, we are saving everytime the user chooses a new row in the picker which could potentially call off a bunch of api calls.
            self.datastore.saveInterestedIn(choice: item.title)
        }
        
        return row
    }
    
    
}

//last section
extension SettingsViewController {
    func addLastSection() {
        let header = createHeader(title: "Account Actions")
        let logOutRow = createLogOutRow()
        let section = SectionFormer(rowFormer: logOutRow).set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
    
    private func createLogOutRow() -> LabelRowFormer<FormLabelCell> {
        let logoutRow = LabelRowFormer<FormLabelCell>().configure { (row: LabelRowFormer<FormLabelCell>) in
            row.text = "Log Out"
            }.onSelected { (_) in
                self.logOut()
        }
        return logoutRow
    }
    
    private func logOut() {
        User.logOut()
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let logInVC = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
        presentVC(logInVC)
    }
}

