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
    var cacheArray: [String] = []
    
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
//        findUserArray(chosenTags: chosenTags, swipeDestination: .mainTinderPage)
    }
    
    func isChosenTagsEmpty(chosenTags: [Tag]) -> Bool {
        if chosenTags.isEmpty {
            delegate?.hideBottomUserArea()
            return true
        }
        return false
    }
    
    fileprivate func searchTagTitle(tagTitle: String) {
        PFCloud.callFunction(inBackground: "searchTags", withParameters: ["title" : tagTitle, "cacheIdentifier" : getMostRecentCache()], block: {
            (results: Any?, error: Error?) -> Void in
                self.analyzeResults(results: results, error: error)
        })
    }
    
    fileprivate func searchSliderTag(tag: DropDownTag) {
        let extremes = convertMaxAndMinValues(tag: tag)
        PFCloud.callFunction(inBackground: "searchSlider", withParameters: ["cacheIdentifier" : getMostRecentCache(), "minValue" : extremes.minValue, "maxValue" : extremes.maxValue, "parseColumnName" : tag.databaseColumnName], block: {
            (results: Any?, error: Error?) -> Void in
                self.analyzeResults(results: results, error: error)
        })
    }
    
    fileprivate func analyzeResults(results: Any?, error: Error?) {
        if let results = results as? [Any] {
            for result in results {
                if let cacheIdentifier = result as? String {
                    self.cacheArray.append(cacheIdentifier)
                } else if let users = result as? [User] {
                    self.findMatchingSwipesForUsers(users: users)
                }
            }
        } else if let error = error {
            print(error)
        }
    }
    
    fileprivate func convertMaxAndMinValues(tag: DropDownTag) -> (minValue: Any, maxValue: Any) {
        var minValue: Any = tag.minValue
        var maxValue: Any = tag.maxValue
        
        switch tag.databaseColumnName {
        case "location":
            minValue = User.current()!.location
        case "birthDate":
            //When working with dates, the higher the age, implies an earlier bday, and the earlier the bday, the lower the number value of the date. (.i.e. April 1, 1996 > Jan 1, 1990)
            minValue = tag.maxValue.years.ago ?? NSNull()
            maxValue = tag.minValue.years.ago ?? NSNull()
        default:
            break
        }
        
        if textContainsPlusSign(text: tag.title) {
            //the tag was something like 50+ mi
            maxValue = NSNull()
        }
        
        return (minValue, maxValue)
    }
    
    fileprivate func getMostRecentCache() -> Any {
        //returning NSNUll because that is how the API reads nil.
        return cacheArray.last ?? NSNull()
    }
    
//    fileprivate func findUserArray(chosenTags: [Tag], swipeDestination: SwipeDestination) {
//        let tuple = createFindUserQuery(chosenTags: chosenTags)
//        
//        tuple.query.findObjectsInBackground { (objects, error) in
//            if let users = objects as? [User] {
//                self.findMatchingSwipesForUsers(users: users, swipeDestination: swipeDestination)
//            } else if let error = error {
//                print(error)
//            }
//        }
//    }
    
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
        delegate?.passdDataToBottomArea(swipes: swipes)
    }
    
    fileprivate func passDataToMainTinderPage(swipes: [Swipe]) {
        delegate?.passDataToMainPage(swipes: swipes)
    }
}

//extension for removing a tag from the search
extension SearchTagsDataStore {
    func removeSearchTags(titleToRemove: String, chosenTags: [Tag]) {
        let removedChosenTags = deleteDependentCaches(titleToRemove: titleToRemove, chosenTags: chosenTags)
        let tuple = getLastNonEmptyCache(index: cacheArray.count - 1)
        let tagTuple = getTagsAfter(index: tuple.index, chosenTags: removedChosenTags)
        let sliderDict = convertSliderTagsToDict(sliderTags: tagTuple.sliderTags)
        
        PFCloud.callFunction(inBackground: "removeSearchTags", withParameters: ["cacheIdentifier" : getMostRecentCache(), "tagTitles" : tagTuple.tagTitles, "sliderTags" : sliderDict], block: {
            (results: Any?, error: Error?) -> Void in
            if let error = error {
                print(error)
            }
        })
    }
    
    private func deleteDependentCaches(titleToRemove: String, chosenTags: [Tag]) -> [Tag] {
        let index: Int? = chosenTags.index { (tag: Tag) -> Bool in
            return tag.title == titleToRemove
        }
        
        if let index = index {
            //replace any caches that have been obseleted with a "". We need to keep the cacheArray at the same length as the chosenTags array. If the user deletes a the second tag in 5 total tags, then the tags that were chosen after it have had their caches obseleted.
            var deletedCaches: [String] = []
            for (i, cache) in cacheArray.enumerated() {
                if i >= index {
                    deletedCaches.append(cache)
                    cacheArray[i] = ""
                }
            }
            
            //get rid of the tag that just got deleted cache
            cacheArray.remove(at: index)
            var chosenTagsCopy = chosenTags
            chosenTagsCopy.remove(at: index)
            return chosenTagsCopy
        }
        
        return []
    }
    
    //Purpose: find the last cache that exists, and pass what index that cache was at, so we know what tags to requery upon from the cache
    private func getLastNonEmptyCache(index: Int) -> (lastCache: Any, index: Int) {
        if cacheArray.isEmpty {
            return (NSNull(), 0)
        } else {
            if cacheArray[index] == "" {
                if index == 0 {
                    return (NSNull(), 0)
                } else {
                    return getLastNonEmptyCache(index: index - 1)
                }
            }
            
            return (cacheArray[index], index)
        }
    }
    
    private func getTagsAfter(index: Int, chosenTags: [Tag]) -> (tagTitles: [String], sliderTags: [DropDownTag]) {
        var tagTitles: [String] = []
        var sliderTags: [DropDownTag] = []
        for (i, tag) in chosenTags.enumerated() {
            if i >= index && !(tag is DropDownTag) {
                if let dropDownTag = tag as? DropDownTag {
                    sliderTags.append(dropDownTag)
                } else {
                    tagTitles.append(tag.title)
                }
            }
        }
        return (tagTitles, sliderTags)
    }
    
    private func convertSliderTagsToDict(sliderTags: [DropDownTag]) -> [[String: Any]] {
        let dictArray: [[String: Any]] = sliderTags.map { (tag: DropDownTag) -> [String: Any] in
            return ["minValue" : tag.minValue, "maxValue" : tag.maxValue, "parseColumnName" : tag.databaseColumnName]
        }
        return dictArray
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
