//
//  SearchTagsDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse
import SCLAlertView

class SearchTagsDataStore: SuperTagDataStore {
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
    var delegate: SearchTagsDataStoreDelegate?
    
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
        findUserArray(chosenTags: chosenTags, swipeDestination: .bottomUserArea)
    }
    
    func getSwipesForMainTinderPage(chosenTags: [Tag]) {
        findUserArray(chosenTags: chosenTags, swipeDestination: .mainTinderPage)
    }
    
    //TODO: the user array should just pull down anyone who is close to any of the tags, they don't have to have all of them.
    fileprivate func findUserArray(chosenTags: [Tag], swipeDestination: SwipeDestination) {
        let tuple = createFindUserQuery(chosenTags: chosenTags)
        
        tuple.query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                if users.isEmpty {
                    _ = SCLAlertView().showInfo("No Users Found", subTitle: "No user has those tags")
                } else {
                    self.convertUsersToSwipes(users: users, swipeDestination: swipeDestination)
                }
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func convertUsersToSwipes(users: [User], swipeDestination: SwipeDestination) {
        
        let userOneParseColumnName = "userOne"
        let userTwoParseColumnName = "userTwo"
        let currentUserIsUserOneQuery = createInnerQuery(currentUserParseColumn: userOneParseColumnName, otherUserParseColumn: userTwoParseColumnName, otherUsers: users)
        let currentUserIsUserTwoQuery = createInnerQuery(currentUserParseColumn: userTwoParseColumnName, otherUserParseColumn: userOneParseColumnName, otherUsers: users)
        
        let orQuery = PFQuery.orQuery(withSubqueries: [currentUserIsUserOneQuery, currentUserIsUserTwoQuery])
        orQuery.includeKey("userOne")
        orQuery.includeKey("userTwo")
        orQuery.findObjectsInBackground { (objects, error) in
            if let parseSwipes = objects as? [ParseSwipe] {
                let swipesToPass: [Swipe] = self.convertParseSwipesToSwipes(users: users, parseSwipes: parseSwipes)
                
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
        let tuple = filterAlreadySwipedUsers(parseSwipes: parseSwipes)
        
        let previouslySwipedUserObjectIds: [String] = tuple.previouslySwipedUsersObjectIds
        var swipesToPass: [Swipe] = tuple.swipesToPass
        
        for user in users where !previouslySwipedUserObjectIds.contains(user.objectId ?? "") {
            let newSwipe = Swipe(otherUser: user, otherUserApproval: false)
            swipesToPass.append(newSwipe)
        }
        
        return swipesToPass
    }
    
    fileprivate func filterAlreadySwipedUsers(parseSwipes: [ParseSwipe]) -> (previouslySwipedUsersObjectIds: [String], swipesToPass: [Swipe]) {
        
        var previouslySwipedUsersObjectIds: [String] = []
        var swipesToPass: [Swipe] = []
        
        for parseSwipe in parseSwipes {
            previouslySwipedUsersObjectIds.append(parseSwipe.otherUser.objectId ?? "")
            
            let swipe = Swipe(otherUser: parseSwipe.otherUser, otherUserApproval: parseSwipe.otherUserApproval)
            swipesToPass.append(swipe)
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
            query.whereKey("location", nearGeoPoint: User.current()!.location, withinMiles: Double(dropDownTag.maxValue))
        case "Age Range":
            //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
            let minAge : Date = dropDownTag.minValue.years.ago ?? Date()
            let maxAge : Date = dropDownTag.maxValue.years.ago ?? Date()
            query.whereKey("birthDate", lessThanOrEqualTo: minAge) //the younger you are, the higher value your birthdate is. So (April 4th, 1996 > April,6th 1990) when comparing
            query.whereKey("birthDate", greaterThanOrEqualTo: maxAge)
        case "Height":
            query.whereKey("height", lessThanOrEqualTo: dropDownTag.maxValue)
            query.whereKey("height", greaterThanOrEqualTo: dropDownTag.minValue)
        default:
            break
        }
        return query
    }
    
    fileprivate func passBottomAreaData(swipes: [Swipe]) {
        delegate?.passdDataToBottomArea(swipes: swipes)
    }
    
    fileprivate func passDataToMainTinderPage(swipes: [Swipe]) {
        delegate?.passDataToMainPage(swipes: swipes)
    }
}

//Mark: After a tag is tapped, show successive tags/find users
extension SearchTagsDataStore {
    //TODO: is this even being used?
    fileprivate func resetDefaultTags() {
        tagChoicesDataArray = tagChoicesDataArray.filter({ (tag: Tag) -> Bool in
            //we only want to have the dropDownTags in the defualt tag
            return tag is DropDownTag
        })
    }
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passDataToMainPage(swipes: [Swipe])
    func passdDataToBottomArea(swipes: [Swipe])
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    func passDataToMainPage(swipes: [Swipe]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: swipes as AnyObject?) //passing swipeArray to the segue
    }
    
    func passdDataToBottomArea(swipes: [Swipe]) {
        if !swipes.isEmpty {
            if theBottomUserArea == nil {
                showBottomUserArea()
            }
            if let bottomUserArea = theBottomUserArea {
                bottomUserArea.reloadData(newData: swipes)
                bottomUserArea.isHidden = false
            }
        } else {
            //swipes are empty
            hideBottomUserArea()
        }
    }
    
    func showBottomUserArea() {
        self.view.endEditing(true)
        theBottomUserArea = BottomUserScrollView(swipes: [], frame: CGRect(x: 0, y: 0, w: self.view.frame.width, h: self.view.frame.height / 3), delegate: self)
        self.view.addSubview(theBottomUserArea!)
        theBottomUserArea?.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(theBottomUserArea!.frame.height)
        }
        theTagScrollView.contentInset.bottom = theBottomUserArea!.frame.height
    }
}
