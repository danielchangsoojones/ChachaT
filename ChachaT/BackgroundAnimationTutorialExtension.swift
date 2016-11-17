//
//  BackgroundAnimationTutorialExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Instructions

extension BackgroundAnimationViewController: CoachMarksControllerDataSource {
    func setUpTutorialCoachingMarks() {
//        if User.current()!.isNew {
            self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
            coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.5)
        
//        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark = coachMarksController.helper.makeCoachMark(for: fakeNavigationBar.rightMenuButton)
        coachMark.allowTouchInsideCutoutPath = true
        return coachMark
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.text = "Let's do your first search"
        coachViews.bodyView.nextLabel.text = "Go!"
        coachViews.bodyView.nextLabel.textColor = CustomColors.JellyTeal
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension BackgroundAnimationViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkWillDisappear coachMark: CoachMark, at index: Int) {
        if index == 0 {
            self.performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: nil)
        }
    }
}
