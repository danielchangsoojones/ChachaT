//
//  SearchTutorialExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Instructions

extension SearchTagsViewController: CoachMarksControllerDataSource {
    func setUpTutorialCoachingMarks() {
        if showTutorial {
            self.coachMarksController.dataSource = self
            coachMarksController.overlay.color = CustomColors.TutorialOverlayColor
            self.coachMarksController.startOn(self)
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return createFirstCoachMark()
        case 1:
            return createSecondCoachMark()
        default:
            //shouldn't reach here
            return CoachMark()
        }
    }
    
    fileprivate func createFirstCoachMark() -> CoachMark {
        let tagView = tagChoicesView.addTag("fun")
        
        tagView.onTap = { (tagView: TagView) in
            self.exampleTagTapped(tagView: tagView)
        }
        var coachMark = coachMarksController.helper.makeCoachMark(for: tagView)
        coachMark.allowTouchInsideCutoutPath = true
        return coachMark
    }
    
    fileprivate func exampleTagTapped(tagView: TagView) {
        coachMarksController.flow.showNext()
    }
    
    fileprivate func createSecondCoachMark() -> CoachMark {
        var coachMark = coachMarksController.helper.makeCoachMark(for: scrollViewSearchView.theGoButton)
        coachMark.allowTouchInsideCutoutPath = true
        return coachMark
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        var bodyView: CoachMarkBodyView!
        switch index {
        case 0:
            bodyView = createFirstBodyView()
        case 1:
            bodyView = createSecondBodyView()
        default:
            //shouldn't reach here
            bodyView = coachMarksController.helper.makeDefaultCoachViews(hintText: "error").bodyView
        }
        
        return (bodyView: bodyView, arrowView: nil)
    }
    
    fileprivate func createFirstBodyView() -> CoachMarkBodyView {
        return MyCoachMarkBodyView(title: "Tap to choose a tag")
    }
    
    fileprivate func createSecondBodyView() -> CoachMarkBodyView {
        return MyCoachMarkBodyView(title: "Find all matching users")
    }
}
