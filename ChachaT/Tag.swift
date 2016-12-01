//
//  Tag.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class Tag {
    var title : String
    var attribute : TagAttributes
    var parseTag: ParseTag?
    var isPending: Bool = false
    
    init(title: String, attribute: TagAttributes, parseTag: ParseTag? = nil) {
        self.title = title
        self.attribute = attribute
        self.parseTag = parseTag
    }
}
