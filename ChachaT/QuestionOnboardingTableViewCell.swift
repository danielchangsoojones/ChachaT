//
//  QuestionOnboardingTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class QuestionOnboardingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var theQuestionButton: ResizableButton!
    
    var index: Int?
    var delegate : QuestionOnboardingTableViewCellDelegate?
    
    
    @IBAction func questionButtonPressed(sender: AnyObject) {
        delegate?.passIndexForButtonPushed(index!)
        delegate?.createQuestionPopUp()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        createQuestionBubbleGUI(theQuestionButton)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
