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
    
    func findUserArray(chosenTags: [Tag]) {
        let tuple = createFindUserQuery(chosenTags: chosenTags)

        tuple.query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                if users.isEmpty {
                    _ = SCLAlertView().showInfo("No Users Found", subTitle: "No user has those tags")
                } else {
                    self.delegate?.passUserArrayToMainPage(users)
                }
            } else if let error = error {
                print(error)
            }
        }
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
}

//Mark: After a tag is tapped, show successive tags/find users
extension SearchTagsDataStore {
    func retrieveSuccessiveTags(chosenTags: [Tag]) {
        let tuple = createFindUserQuery(chosenTags: chosenTags)
        
        tuple.query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                
                //TODO: once a better backend is implemented, it would be able to see if we have already swiped any of these users and actually pass me the swipes accordingly. For now, I am just making them totally new swipes
                let newSwipes: [Swipe] = users.map({ (user: User) -> Swipe in
                    return Swipe(otherUser: user, otherUserApproval: false)
                })
                self.delegate?.passdDataToBottomArea(swipes: newSwipes)
                
                let query = JointParseTagToUser.query()! as! PFQuery<JointParseTagToUser>
                query.whereKey("user", containedIn: users) //find any tags related to the chosen users
                query.whereKey("tagTitle", notContainedIn: tuple.chosenTitleArray) //don't include any tags that have already been chosen
                query.includeKey("parseTag")
                query.findObjectsInBackground(block: { (joints, error) in
                    self.resetDefaultTags()
                    if let joints = joints {
                        let successiveTags: [Tag] = joints.map({ (joint: JointParseTagToUser) -> Tag in
                            let tag = Tag(title: joint.lowercaseTagTitle, attribute: .generic)
                            return tag
                        })
                        self.tagChoicesDataArray.append(contentsOf: successiveTags)
                    } else if let error = error {
                        print(error)
                    }
                    self.delegate?.setChoicesViewTagsArray(self.tagChoicesDataArray)
                })
            }
        }
    }
    
    fileprivate func resetDefaultTags() {
        tagChoicesDataArray = tagChoicesDataArray.filter({ (tag: Tag) -> Bool in
            //we only want to have the dropDownTags in the defualt tag
            return tag is DropDownTag
        })
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
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User])
    func passdDataToBottomArea(swipes: [Swipe])
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: userArray as AnyObject?) //passing userArray to the segue
    }
    
    func passdDataToBottomArea(swipes: [Swipe]) {
        showBottomUserArea()
        if let bottomUserArea = theBottomUserArea {
            bottomUserArea.reloadData(newData: swipes)
        }
    }
    
    func showBottomUserArea() {
        theBottomUserArea = BottomUserScrollView(swipes: [], frame: CGRect(x: 0, y: 0, w: self.view.frame.width, h: 100))
        self.view.addSubview(theBottomUserArea!)
        theBottomUserArea?.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(theBottomUserArea!.frame.height)
        }
        theTagScrollView.contentInset.bottom = theBottomUserArea!.frame.height
    }
}
