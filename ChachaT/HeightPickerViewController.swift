//
//  HeightPickerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class HeightPickerViewController: UIViewController {
    let feetArray: [Int] = [4,5,6]
    //Dependency injection for passing the height back to the viewController that needs it
    var passHeight: ((_ height: String, _ totalInches: Int) -> Void)?
    
    @IBOutlet weak var theHeightPicker: UIPickerView!
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        //nothing should happen if they chose the title headings
        if theHeightPicker.selectedRow(inComponent: 0) != 0 && theHeightPicker.selectedRow(inComponent: 1) != 0 {
            let feet = feetArray[theHeightPicker.selectedRow(inComponent: 0) - 1]
            let inches = theHeightPicker.selectedRow(inComponent: 1) - 1
            let height = feet.toString + "'" + inches.toString + "\""
            let totalInches = feet * 12 + inches
            if let passHeight = passHeight {
                passHeight(height, totalInches)
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialHeight()
        // Do any additional setup after loading the view.
    }
    
    func setInitialHeight() {
        let tuple = User.current()!.calculateFeetAndInchesOfHeight()
        theHeightPicker.selectRow(feetArray.index(of: tuple.feet)?.advanced(by: 1) ?? 0, inComponent: 0, animated: false)
        let doesHeightExist: Bool = User.current()!.height > 0
        theHeightPicker.selectRow(doesHeightExist ? tuple.inches + 1 : 0, inComponent: 1, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HeightPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            //the feet row
            //Add one because we have the heading views
            return feetArray.count + 1
        } else if component == 1 {
            //the inches column
            return 12 + 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            //give a title heading
            return component == 0 ? "Feet" : "Inches"
        } else if component == 0 {
            //the feet row
            return feetArray[row - 1].toString
        } else if component == 1 {
            //the inches column
            return (row - 1).toString
        }
        return ""
    }

    
}
