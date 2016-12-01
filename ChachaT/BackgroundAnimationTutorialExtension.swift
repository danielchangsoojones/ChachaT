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
        coachMark.gapBetweenCoachMarkAndCutoutPath = 0
        coachMark.gapBetweenBodyAndArrow = 0
        return coachMark
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        //TODO: one day, I want to figure out how to make an arrowView, just can't figure it out at the moment. 
        let bodyView = MyCoachMarkBodyView(title: "Let's do your first search")
        return (bodyView: bodyView, arrowView: nil)
    }
}

extension BackgroundAnimationViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkWillDisappear coachMark: CoachMark, at index: Int) {
        if index == 0 {
            self.performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: nil)
        }
    }
}
