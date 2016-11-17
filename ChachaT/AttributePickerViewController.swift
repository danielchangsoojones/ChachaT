//
//  AttributePickerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Static

class AttributePickerViewController: TableViewController {
    
    var passedAction: ((String) -> ())?
    var sectionTitle: String = ""
    var rowTitles: [String] = []
    var previouslyChosenTitle: String = ""
    
    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.sections = [
            Section(header: "Hi", rows: createRows())
        ]
        // Do any additional setup after loading the view.
    }
    
    fileprivate func createRows() -> [Row] {
        var rows: [Row] = []
        for title in rowTitles {
            rows.append(createRow(title: title))
        }
        return rows
    }
    
    func createRow(title: String) -> Row {
        let selection = createSelection(title: title)
        var row: Row!
        if title == previouslyChosenTitle {
            //add a checkmark to that row
            row = Row(text: title, selection: selection, accessory: .checkmark)
        } else {
            row = Row(text: title, selection: selection)
        }
        return row
    }
    
    fileprivate func createSelection(title: String) -> Selection {
        return {
            _ = self.passedAction!(title)
            self.popVC()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
