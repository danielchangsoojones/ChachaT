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
    
    //TODO: make the tagView only go as tall as the keyboard height because the keyboard is blocking the last few tags. Or give the scroll view some extra spacing to fix this.
    override func awakeFromNib() {
        addingMenuTagListView.addTag("hi")
        setBackgroundViewProperties()
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