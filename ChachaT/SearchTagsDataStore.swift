//
//  SearchTagsDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class SearchTagsDataStore: SuperTagDataStore {
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
    var delegate: SearchTagsDataStoreDelegate?
    var parseSwipes: [ParseSwipe] = []
    var swipes: [Swipe] = []
    
    init(delegate: SearchTagsDataStoreDelegate) {
        super.init(superTagDelegate: delegate)
        self.delegate = delegate
        setSpecialtyTagsIntoDefaultView()
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    //TODO: I probably shouldn't be using a global variable for the tag array. 
    //TODO: cache this on the first time, so we can keep going back to it.
    func setSpecialtyTagsIntoDefaultView() {
        let query = DropDownCategory.query()! as! PFQuery<DropDownCategory>
        query.includeKey("innerTags")
        query.findObjectsInBackground { (categories, error) in
            if let categories = categories {
                for dropDownCategory in categories {
                    var dropDownTag: DropDownTag?
                    switch dropDownCategory.type {
                    case DropDownAttributes.tagChoices.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: dropDownCategory.innerTagTitles, dropDownAttribute: DropDownAttributes.tagChoices)
                    case DropDownAttributes.singleSlider.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, maxValue: dropDownCategory.max, suffix: dropDownCategory.suffix, dropDownAttribute: DropDownAttributes.singleSlider)
                    case DropDownAttributes.rangeSlider.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, minValue: dropDownCategory.min, maxValue: dropDownCategory.max, suffix: dropDownCategory.suffix, dropDownAttribute: DropDownAttributes.rangeSlider)
                    default:
                        break
                    }
                    dropDownTag?.databaseColumnName = dropDownCategory.parseColumnName ?? ""
                    if let dropDownTag = dropDownTag {
                        self.tagChoicesDataArray.append(dropDownTag)
                    }
                }
                self.delegate?.setChoicesViewTagsArray(self.tagChoicesDataArray)
                
                //adding generic tags after the drop down tags because I want them to go below the other drop down tags
                self.setGenericTagsIntoDefaultView()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    //TODO: right now just pulling the newest 50, but eventually, we want to pull trending, even just random tags everytime, or past search results.
    fileprivate func setGenericTagsIntoDefaultView() {
        let query = ParseTag.query()! as! PFQuery<ParseTag>
        //TODO: figure out the height/width of the screen and how many tags to show in each case.
        query.limit = 50
        
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                let tags: [Tag] = parseTags.map({ (parseTag: ParseTag) -> Tag in
                    let tag = Tag(title: parseTag.tagTitle, attribute: .generic)
                    return tag
                })
                self.delegate?.appendTagsToTagChoices(tags: tags)
            } else if let error = error {
                print(error)
            }
        }
    }
}

//Mark: For finding the users
extension SearchTagsDataStore {
    func searchTags(chosenTags: [Tag]) {
        let query = ParseUserTag.query()!
        query.limit = 20
        query.includeKey("user")
        
        var innerQuery = User.query()!
        innerQuery.whereKeyExists("profileImage")
        
        var tagTitleArray: [String] = []
        for tag in chosenTags {
            if let dropDownTag = tag as? DropDownTag {
                innerQuery = addSliderQueryComponents(dropDownTag: dropDownTag, query: innerQuery)
            } else {
                tagTitleArray.append(tag.title)
            }
        }
        if !tagTitleArray.isEmpty {
            //query any tags with the title
            innerQuery.whereKey("tagsArray", containsAllObjectsIn: tagTitleArray)
            query.whereKey("tagTitle", containedIn: tagTitleArray)
        }
        
        query.whereKey("user", matchesQuery: innerQuery)
        findUsers(query: query)
    }
    
    fileprivate func findUsers(query: PFQuery<PFObject>) {
        query.findObjectsInBackground { (objects, error) in
            if let parseUserTags = objects as? [ParseUserTag] {
                let users: [User] = parseUserTags.map({ (parseUserTag: ParseUserTag) -> User in
                    return parseUserTag.user
                })
                self.findMatchingSwipesForUsers(users: users)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func getSwipesForMainTinderPage(chosenTags: [Tag]) {
        //TODO: technically, if the passDataToBottom area query has not completed by the time they hit this button, then it won't pass the newest swipes in time.
        passDataToMainTinderPage(swipes: self.swipes)
    }
    
    //TODO: move this to cloud code because we have to run another query? or at least pass the users before we conver them to swipes
    //Purpose: we found any users who matched the swipes, now we need to make check if a parseSwipe exists for that particular user relative to this user, so if the user swipes on that person, we will know whether to make it a match or not.
    fileprivate func findMatchingSwipesForUsers(users: [User]) {
        let userOneParseColumnName = "userOne"
        let userTwoParseColumnName = "userTwo"
        let currentUserIsUserOneQuery = createInnerQuery(currentUserParseColumn: userOneParseColumnName, otherUserParseColumn: userTwoParseColumnName, otherUsers: users)
        let currentUserIsUserTwoQuery = createInnerQuery(currentUserParseColumn: userTwoParseColumnName, otherUserParseColumn: userOneParseColumnName, otherUsers: users)
        
        let orQuery = PFQuery.orQuery(withSubqueries: [currentUserIsUserOneQuery, currentUserIsUserTwoQuery])
        orQuery.includeKey("userOne")
        orQuery.includeKey("userTwo")
        
        self.parseSwipes.removeAll()
        orQuery.findObjectsInBackground { (objects, error) in
            if let parseSwipes = objects as? [ParseSwipe] {
                let swipesToPass: [Swipe] = self.convertParseSwipesToSwipes(users: users, parseSwipes: parseSwipes)
                self.parseSwipes = parseSwipes
                self.passBottomAreaData(swipes: swipesToPass)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func convertParseSwipesToSwipes(users: [User], parseSwipes: [ParseSwipe]) -> [Swipe] {
        let tuple = createSwipeForAlreadySwipedUsers(parseSwipes: parseSwipes)
        
        let previouslySwipedUserObjectIds: [String] = tuple.previouslySwipedUsersObjectIds
        var swipesToPass: [Swipe] = tuple.swipesToPass
        
        for user in users where !previouslySwipedUserObjectIds.contains(user.objectId ?? "") {
            //we create a parseSwipe, so we can have it when we want to check what parseSwipe to save.
            let newParseSwipe = ParseSwipe(otherUser: user, currentUserApproval: false)
            //If they don't have an existing swipe in the database, then we create a new one for them with the defualt starting values. This means that the currentUser has never swiped this user.
            let newSwipe = Swipe(otherUser: user, otherUserApproval: false, parseSwipe: newParseSwipe)
            self.parseSwipes.append(newParseSwipe)
            swipesToPass.append(newSwipe)
        }
        
        return swipesToPass
    }
    
    fileprivate func createSwipeForAlreadySwipedUsers(parseSwipes: [ParseSwipe]) -> (previouslySwipedUsersObjectIds: [String], swipesToPass: [Swipe]) {
        
        var previouslySwipedUsersObjectIds: [String] = []
        var swipesToPass: [Swipe] = []
        
        for parseSwipe in parseSwipes {
            let otherUserObjectId: String = parseSwipe.otherUser.objectId ?? ""
            if !previouslySwipedUsersObjectIds.contains(otherUserObjectId) {
                //avoiding any duplicate users. This could happen if somehow two swipes existed for the same user. Which technically shouldn't happen anyway, but this is an extra safety precaution to make sure the currentUser doesn't see duplicate users.
                previouslySwipedUsersObjectIds.append(otherUserObjectId)
                let swipe = convertParseSwipeToSwipe(parseSwipe: parseSwipe)
                swipesToPass.append(swipe)
            }
        } 
        
        return (previouslySwipedUsersObjectIds, swipesToPass)
    }
    
    fileprivate func createInnerQuery(currentUserParseColumn: String, otherUserParseColumn: String, otherUsers: [User]) -> PFQuery<PFObject> {
        let query = ParseSwipe.query()!
        query.whereKey(currentUserParseColumn, equalTo: User.current()!)
        query.whereKey(otherUserParseColumn, containedIn: otherUsers)
        return query
    }
    
    fileprivate func addSliderQueryComponents(dropDownTag: DropDownTag, query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        var newQuery: PFQuery<PFObject> = query
        
        switch dropDownTag.databaseColumnName {
        case "location":
            if !textContainsPlusSign(text: dropDownTag.title) {
                newQuery.whereKey("location", nearGeoPoint: User.current()!.location, withinMiles: Double(dropDownTag.maxValue))
            }
        case "birthDate":
            //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
            //Remember, a newer date has a higher value
            let minDate : Date = dropDownTag.maxValue.years.ago ?? Date()
            let maxDate : Date = dropDownTag.minValue.years.ago ?? Date()
            newQuery = addSliderQuery(title: dropDownTag.title, min: minDate, max: maxDate, databaseColumnName: dropDownTag.databaseColumnName, query: newQuery)
        default:
            newQuery = addSliderQuery(title: dropDownTag.title, min: dropDownTag.minValue, max: dropDownTag.maxValue, databaseColumnName: dropDownTag.databaseColumnName, query: newQuery)
        }
        return newQuery
    }
    
    fileprivate func addSliderQuery(title: String, min: Any, max: Any, databaseColumnName: String, query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        if !textContainsPlusSign(text: title) {
            query.whereKey(databaseColumnName, lessThanOrEqualTo: max)
        }
        query.whereKey(databaseColumnName, greaterThanOrEqualTo: min)
        return query
    }
    
    //TODO: This is kind of a hacky way to see if the slider is at its max value. Really, we should be passing the currentValue of the slider and comparing to max value> But, this works for now until code can be refactored
    fileprivate func textContainsPlusSign(text: String) -> Bool {
        let plusSign = "+"
        return text.contains(plusSign)
    }
    
    fileprivate func passBottomAreaData(swipes: [Swipe]) {
        self.swipes = swipes
        delegate?.passdDataToBottomArea(swipes: swipes)
    }
    
    fileprivate func passDataToMainTinderPage(swipes: [Swipe]) {
        delegate?.passDataToMainPage(swipes: swipes)
    }
}

//extension for removing a tag from the search
extension SearchTagsDataStore {
    func removeSearchTags(chosenTags: [Tag]) {
        if !isChosenTagsEmpty(chosenTags: chosenTags) {
            searchTags(chosenTags: chosenTags)
        }
    }
    
    fileprivate func isChosenTagsEmpty(chosenTags: [Tag]) -> Bool {
        if chosenTags.isEmpty {
            delegate?.hideBottomUserArea()
            return true
        }
        return false
    }
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passDataToMainPage(swipes: [Swipe])
    func passdDataToBottomArea(swipes: [Swipe])
    func appendTagsToTagChoices(tags: [Tag])
    func hideBottomUserArea()
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    func passDataToMainPage(swipes: [Swipe]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: swipes as AnyObject?) //passing swipeArray to the segue
    }
    
    func passdDataToBottomArea(swipes: [Swipe]) {
        //had to end editing on the scrollViewSearchView, not the self.view because scrollViewSearchView is in its own separate view in the nav bar
            if theBottomUserArea == nil {
                showBottomUserArea(swipes: swipes)
            }
            if let bottomUserArea = theBottomUserArea {
                if bottomUserArea.frame.y == self.view.frame.maxY {
                    //the bottomUserArea is pushed off the screen currently
                    toggleBottomUserArea(show: true)
                }
                if swipes.isEmpty {
                    showEmptyState()
                } else {
                    hideEmptyState()
                    bottomUserArea.reloadData(newData: swipes)
                }
            }
    }
    
    func appendTagsToTagChoices(tags: [Tag]) {
        if !showTutorial {
            self.tagChoicesDataArray.append(contentsOf: tags)
            for tag in tags {
                _ = tagChoicesView.addTag(tag.title)
            }
        }
    }
}
