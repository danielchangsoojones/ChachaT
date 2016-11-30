//
//  TagCreationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class TagCreationViewController: UIViewController {
    var creationTagListView: CreationTagListView = CreationTagListView(frame: CGRect.zero)
    var creationMenuView: CreationMenuView!
    var theCreationTagView: CreationTagView!
    
    convenience init(tags: [Tag]) {
        self.init(nibName: nil, bundle: nil)
        layoutCreationTagListView()
        setCreationTagView()
    }
    
    //In order to use an init in view controller, must use a convenience init that calls this init and then passes nil, if not in storyboard.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCreationTagView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setCreationTagView() {
        theCreationTagView = creationTagListView.creationTagView
        theCreationTagView.setDelegate(delegate: self)
    }
    
    private func layoutCreationTagListView() {
        self.view.addSubview(creationTagListView)
        creationTagListView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

extension TagCreationViewController: CreationTagViewDelegate {
    func textFieldDidChange(_ searchText: String) {
        if creationMenuView == nil {
                    //when we use the mac simulator, sometimes, the keyboard is not toggled. And, the creationMenuView uses the height of the keyboard to calculate its height. Hence, if the keyboard doesn't show, then the creationMenuView would be nil. By just having a nil check here, we stop the mac simulator from crashing, even though a real device would not need this code/wouldn't crash.
            createTagMenuView(0)
        }
        creationMenuView.removeAllTags()
        creationMenuView.isHidden = false
        //we already check if the text is empty over in the CreationTagView class
        //TODO: run a search for the tags in this class or in the super class?
//        dataStore.searchForTags(searchText: searchText)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //TODO: hide all tagViews that aren't the CreationTagView, meaning clear the screen.
        creationMenuView?.isHidden = false
    }
    
    //Calls this function when the tap is recognized anywhere on the screen that is not a tappable object.
    func dismissTheKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resetTextField()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return false //for some reason, I have to return false in order for the textField to resignTheFirst responder propoerly
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //the return button hit
        if let tagView = creationMenuView.choicesTagListView.tagViews.first, let currentTitle = tagView.currentTitle {
            creationMenuView.tagPressed(currentTitle, tagView: tagView, sender: creationMenuView.choicesTagListView)
        }
        return true
    }
    
    func resetTextField() {
        theCreationTagView.searchTextField.text = ""
        dismissTheKeyboard() //calls the textFieldDidEndEditing method, which hides the CreationMenuView
        creationMenuView?.isHidden = true
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        //creating the creationMenuView here because we only want it to be visible above the keyboard, so they can scroll through all available tags.
        //But, we can only get the keyboard height through this notification.
        createTagMenuView(keyboardHeight)
    }
    
    func createTagMenuView(_ keyboardHeight: CGFloat) {
        if creationMenuView == nil {
            creationMenuView = CreationMenuView.instanceFromNib(self)
        }
        //TODO: should this add subview be up in the nil check area? we don't want to add this multiple times to the view
        self.view.addSubview(creationMenuView)
        //TODO: I don't know why, but by setting the hidden value on the tagMenuView when I want it to disappear, it makes the height constraint = 0, so I need to remake the constraints to make the CreationMenu show up a second time. This fixes it. But, might be a better way, where I don't have to set constraints every time the keyboard appears.
        creationMenuView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(keyboardHeight)
            //We can't just snp the top to addingTagView.snp.bottom, becuase when we rearrange the tagViews, the constraints get messed up. So, we snp it to the bottom of the addingTagView but make sure that the offset is a constant.
            make.top.equalTo(creationTagListView.snp.top).offset(theCreationTagView.frame.height)
        }
    }
}

extension TagCreationViewController: AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String) {
        creationTagListView.insertTagViewAtIndex(1, title: title)
        resetTextField()
        //TODO: pass a delegate to make it save the tagTitle however it is supposed to save
//        dataStore.saveNewTag(title: title)
    }
}
