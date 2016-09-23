//
//  CreationMenuView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(_ title: String, tagView: TagView?)
}

//This is the menu that appears when you start typing in the CreationTagView. It shows all the available tags in the database, and if none exist, then it shows you how to create a new one.
class CreationMenuView: UIView {
    
    @IBOutlet weak var choicesTagListView: ChachaChoicesTagListView!
    @IBOutlet weak var backgroundView: UIView!
    var tableView : UITableView?
    var newTagTitle: String = ""
    
    var delegate: AddingTagMenuDelegate?
    
    //TODO: make the tagView only go as tall as the keyboard height because the keyboard is blocking the last few tags. Or give the scroll view some extra spacing to fix this.
    override func awakeFromNib() {
        choicesTagListView.delegate = self
    }
    
    func reset() {
        removeAllTags()
        tableView?.isHidden = true
    }
    
    func removeAllTags() {
        choicesTagListView.removeAllTags()
    }
    
    class func instanceFromNib(_ delegate: AddingTagMenuDelegate) -> CreationMenuView {
        // the nibName has to match your class file and your xib file
        let nib = UINib(nibName: "CreationMenuView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CreationMenuView
        nib.delegate = delegate
        return nib
    }
}

extension CreationMenuView: UITableViewDelegate, UITableViewDataSource {
    enum MenuType {
        case tags
        case table
    }
    
    func toggleMenuType(_ menuType: MenuType, newTagTitle: String?, tagTitles: [String]?) {
        //if the menu is supposed to be tags, then we want it hidden
        tableView?.isHidden = menuType == .tags
        switch menuType {
            case .tags:
                addTagsToTagListView(tagTitles)
            case .table:
                if let newTagTitle = newTagTitle {
                    if let tableView = self.tableView {
                        //tableView already exists, update the data according to the newTagTitle
                        self.newTagTitle = newTagTitle
                        tableView.reloadData()
                    } else {
                        //create a whole tableview, since it has not been created yet.
                        createNewTableView(newTagTitle)
                    }
                }
        }
    }
    
    fileprivate func addTagsToTagListView(_ tagTitles: [String]?) {
        if let tagTitles = tagTitles {
            for (index, tagTitle) in tagTitles.enumerated() {
                let tagView = choicesTagListView.addTag(tagTitle)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.isSelected = true
                }
            }
        }
    }
    
    fileprivate func createNewTableView(_ newTagTitle: String) {
        self.newTagTitle = newTagTitle
        tableView = UITableView()
        tableView!.delegate = self
        tableView!.dataSource = self
        self.addSubview(tableView!)
        tableView!.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    //TODO: have the tableView only be the height the cells that show, as in don't have extra useless cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if (indexPath as NSIndexPath).row == 0 {
            //the first row should be create new tag
            cell.textLabel?.text = "Create new tag: \(newTagTitle)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            delegate?.addNewTagToTagChoiceView(newTagTitle, tagView: nil)
            reset()
            self.isHidden = true
        }
    }
}

extension CreationMenuView: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        delegate?.addNewTagToTagChoiceView(title, tagView: tagView)
        reset()
    }
}
