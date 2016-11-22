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
        if showTutorial {
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            coachMarksController.overlay.color = CustomColors.TutorialOverlayColor
            self.coachMarksController.startOn(self)
        }
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
        let bodyView = Tutorial.createBodyView(hintText: "let's do your first search")
        let arrowView = CoachMarkArrowDefaultView(orientation: .top)
        return (bodyView: bodyView, arrowView: arrowView)
    }
}

extension BackgroundAnimationViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkWillDisappear coachMark: CoachMark, at index: Int) {
        if index == 0 {
            self.performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: nil)
        }
    }
}
