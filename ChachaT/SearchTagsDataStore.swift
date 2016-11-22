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
    fileprivate enum SwipeDestination {
        case bottomUserArea
        case mainTinderPage
    }
    
    func getSwipesForBottomArea(chosenTags: [Tag]) {
        if !isChosenTagsEmpty(chosenTags: chosenTags) {
            findUserArray(chosenTags: chosenTags, swipeDestination: .bottomUserArea)
        }
    }
    
    func getSwipesForMainTinderPage(chosenTags: [Tag]) {
        findUserArray(chosenTags: chosenTags, swipeDestination: .mainTinderPage)
    }
    
    func isChosenTagsEmpty(chosenTags: [Tag]) -> Bool {
        if chosenTags.isEmpty {
            delegate?.hideBottomUserArea()
            return true
        }
        return false
    }
    
    //TODO: the user array should just pull down anyone who is close to any of the tags, they don't have to have all of them.
    fileprivate func findUserArray(chosenTags: [Tag], swipeDestination: SwipeDestination) {
        let tuple = createFindUserQuery(chosenTags: chosenTags)
        
        tuple.query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                self.findMatchingSwipesForUsers(users: users, swipeDestination: swipeDestination)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    //Purpose: we found any users who matched the swipes, now we need to make check if a parseSwipe exists for that particular user relative to this user, so if the user swipes on that person, we will know whether to make it a match or not.
    fileprivate func findMatchingSwipesForUsers(users: [User], swipeDestination: SwipeDestination) {
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
                
                if swipeDestination == .bottomUserArea {
                    self.passBottomAreaData(swipes: swipesToPass)
                } else if swipeDestination == .mainTinderPage {
                    self.passDataToMainTinderPage(swipes: swipesToPass)
                }
                
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
    
    fileprivate func createFindUserQuery(chosenTags: [Tag]) -> (query: PFQuery<PFObject>, chosenTitleArray: [String]) {
        var query = User.query()!
        query.whereKeyExists("profileImage")
        
        var tagTitleArray: [String] = []
        for tag in chosenTags {
            if let dropDownTag = tag as? DropDownTag {
                query = addSliderQueryComponents(dropDownTag: dropDownTag, query: query)
            } else {
                tagTitleArray.append(tag.title)
            }
        }
        if !tagTitleArray.isEmpty {
            //query any tags with the title
            let innerQuery = ParseTag.query()!
            innerQuery.whereKey("title", containedIn: tagTitleArray)
            query.whereKey("tags", matchesQuery: innerQuery)
        }
        return (query, tagTitleArray)
    }
    
    func addSliderQueryComponents(dropDownTag: DropDownTag, query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        switch dropDownTag.specialtyCategory {
        //TODO: these cases should be based upon the parse column name
        case "Distance":
            if !textContainsPlusSign(text: dropDownTag.title) {
                query.whereKey("location", nearGeoPoint: User.current()!.location, withinMiles: Double(dropDownTag.maxValue))
            }
        case "Age Range":
            //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
            let minAge : Date = dropDownTag.minValue.years.ago ?? Date()
            let maxAge : Date = dropDownTag.maxValue.years.ago ?? Date()
            query.whereKey("birthDate", lessThanOrEqualTo: minAge) //the younger you are, the higher value your birthdate is. So (April 4th, 1996 > April,6th 1990) when comparing
            if !textContainsPlusSign(text: dropDownTag.title) {
                query.whereKey("birthDate", greaterThanOrEqualTo: maxAge)
            }
        case "Height":
            if !textContainsPlusSign(text: dropDownTag.title) {
                query.whereKey("height", lessThanOrEqualTo: dropDownTag.maxValue)
            }
            query.whereKey("height", greaterThanOrEqualTo: dropDownTag.minValue)
        default:
            break
        }
        return query
    }
    
    //TODO: This is kind of a hacky way to see if the slider is at its max value. Really, we should be passing the currentValue of the slider and comparing to max value> But, this works for now until code can be refactored
    fileprivate func textContainsPlusSign(text: String) -> Bool {
        let plusSign = "+"
        return text.contains(plusSign)
    }
    
    fileprivate func passBottomAreaData(swipes: [Swipe]) {
        delegate?.passdDataToBottomArea(swipes: swipes)
    }
    
    fileprivate func passDataToMainTinderPage(swipes: [Swipe]) {
        delegate?.passDataToMainPage(swipes: swipes)
    }
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passDataToMainPage(swipes: [Swipe])
    func passdDataToBottomArea(swipes: [Swipe])
    func appendTagsToTagChoices(tags: [Tag])
    func hideBottomUserArea()
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    //Yes, this kind of breaks some of the code cleanliness to pass the parseSwipes to the next view controller, but the parseSwipes are needed in the next data store. There isn't really a better way.
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
