//
//  AddingTagMenuView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AddingTagMenuView: UIView {
    
    @IBOutlet weak var addingMenuTagListView: ChachaChoicesTagListView!
    @IBOutlet weak var backgroundView: UIView!
    var newTagTitle: String = ""
    
    var delegate: AddingTagMenuDelegate?
    
    //TODO: make the tagView only go as tall as the keyboard height because the keyboard is blocking the last few tags. Or give the scroll view some extra spacing to fix this.
    override func awakeFromNib() {
        setBackgroundViewProperties()
        addingMenuTagListView.delegate = self
    }
    
    func setDelegate(delegate: AddingTagMenuDelegate) {
        self.delegate = delegate
    }
    
    func setBackgroundViewProperties() {
//        backgroundView.alpha = 0.75
    }
    
    func addTag(title: String) -> TagView {
        let tagView = addingMenuTagListView.addTag(title)
        return tagView
    }
    
    func removeAllTags() {
        addingMenuTagListView.removeAllTags()
    }
    
    class func instanceFromNib() -> AddingTagMenuView {
        // the nibName has to match your class file and your xib file
        return UINib(nibName: "AddingTagMenuView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AddingTagMenuView
    }
}

extension AddingTagMenuView: UITableViewDelegate, UITableViewDataSource {
    //TODO: make a public function to call that is better naming convention
    func createNewTagTableView(newTagTitle: String) {
        self.newTagTitle = newTagTitle
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        //TODO: somehow hide the scroll view/disable because the tableview has an automatic scroll view. But, can't just remove because the user might hit backspace
    }
    
    //TODO: have the tableView only be the height the cells that show, as in don't have extra useless cells.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            //the first row should be create new tag
            cell.textLabel?.text = "Create new tag: \(newTagTitle)"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            delegate?.addNewTagToTagChoiceView(newTagTitle, tagView: nil)
            self.removeFromSuperview()
        }
    }
}

extension AddingTagMenuView: TagListViewDelegate {
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        delegate?.addNewTagToTagChoiceView(title, tagView: tagView)
    }
}

protocol AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String, tagView: TagView?)
}

extension AddingTagsToProfileViewController: AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String, tagView: TagView?) {
        //also passing the TagView because I get the feeling that I might need it in the future.
        tagChoicesView.insertTagViewAtIndex(1, title: title, tagView: tagView)
        if let addingTagView = findAddingTagTagView() {
            addingTagView.searchTextField.text = ""
            resignFirstResponder()
        }
        dataStore.saveNewTag(title)
    }
    
}