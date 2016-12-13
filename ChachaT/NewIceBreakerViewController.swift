//
//  NewIceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Instructions

protocol NewIceBreakerControllerDelegate {
    func passUpdated(iceBreaker: IceBreaker)
}

class NewIceBreakerViewController: UIViewController {
    struct Constant {
        static let maxCharacterCount: Int = 150
    }
    
    var theNewIceBreakerView: NewIceBreakerView!
    var theTextView: UITextView!
    var theCharCountLabel: UILabel!
    var theInfoIndicator: UIButton!
    
    var iceBreaker: IceBreaker!
    var dataStore: NewIceBreakerDataStore = NewIceBreakerDataStore()
    var delegate: NewIceBreakerControllerDelegate?
    let coachMarksController = CoachMarksController()
    
    init(iceBreaker: IceBreaker) {
        super.init(nibName: nil, bundle: nil)
        self.iceBreaker = iceBreaker
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        textViewSetup()
        navBarSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coachMarksController.stop(immediately: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func viewSetup() {
        theNewIceBreakerView = NewIceBreakerView(frame: self.view.bounds)
        theNewIceBreakerView.theSaveButton.addTarget(self, action: #selector(saveButtonPressed(sender:)), for: .touchUpInside)
        theCharCountLabel = theNewIceBreakerView.theCharCountLabel
        self.view.addSubview(theNewIceBreakerView)
    }
    
    func saveButtonPressed(sender: UIButton) {
        if theTextView.text != "" {
            iceBreaker.text = theTextView.text
        }
        
        //TODO: technically when they're saving a totally new ice breaker, then we go back to the screen, and if they delete it, then it won't delete because no ParseIceBreaker exists yet
        dataStore.save(iceBreaker: iceBreaker)
        delegate?.passUpdated(iceBreaker: iceBreaker)
        popVC()
    }
}

//nav bar setup
extension NewIceBreakerViewController: CoachMarksControllerDataSource {
    fileprivate func navBarSetup() {
        theInfoIndicator = theNewIceBreakerView.theInfoIndicator
        theInfoIndicator.addTarget(self, action: #selector(infoIndicatorPressed(sender:)), for: .touchUpInside)
        self.navigationItem.titleView = theNewIceBreakerView.theTitleView
    }
    
    func infoIndicatorPressed(sender: UIButton) {
        coachMarksController.dataSource = self
        coachMarksController.startOn(self)
        coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.5)
        coachMarksController.overlay.allowTap = true
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: theInfoIndicator)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.text = "An ice breaker is the first message that gets sent when you match with someone."
        coachViews.bodyView.nextLabel.text = "Ok!"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension NewIceBreakerViewController: UITextViewDelegate {
    fileprivate func textViewSetup() {
        theTextView = theNewIceBreakerView.theTextView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        theTextView.delegate = self
        if let initialText = iceBreaker.text {
            theTextView.text = initialText
        }
        //TODO: change to "ex: what are your two truths and a lie?"
        theNewIceBreakerView.setTextView(placeholder: "ex: So, how would you hide a giraffe from the government?")
        theCharCountLabel.text = Constant.maxCharacterCount.toString
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            theTextView.contentInset.bottom = keyboardSize.height
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        return newLength < Constant.maxCharacterCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.characters.count
        let charactersLeft = Constant.maxCharacterCount - characterCount
        theCharCountLabel.text = "\(charactersLeft)"
    }
    
}
