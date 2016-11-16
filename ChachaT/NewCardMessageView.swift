//
//  NewCardMessageView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/15/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

protocol NewCardMessageDelegate {
    func respondToMessage()
}

class NewCardMessageView: UIView {
    fileprivate struct NewCardMessageConstants {
        static let textColor: UIColor = UIColor.white
        static let titleFont: UIFont = UIFont.systemFont(ofSize: 24)
        static let subtitleFont: UIFont = UIFont.systemFont(ofSize: 14)
    }
    
    var messageImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "PaperAriplane"))
    var theStackView: UIStackView = UIStackView()
    
    var delegate: NewCardMessageDelegate?
    
    init(frame: CGRect, delegate: NewCardMessageDelegate) {
        super.init(frame: frame)
        self.backgroundColor = CustomColors.SilverChaliceGrey.withAlphaComponent(0.87)
        self.delegate = delegate
        addMessageImage()
        createStackView()
    }
    
    fileprivate func addMessageImage() {
        messageImageView.contentMode = .scaleAspectFit
        self.addSubview(messageImageView)
        messageImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(self.frame.height * 0.5)
        }
    }
    
    fileprivate func createStackView() {
        theStackView.axis = .vertical
        theStackView.alignment = .leading
        theStackView.distribution = .fillProportionally
        self.addSubview(theStackView)
        theStackView.snp.makeConstraints { (make) in
            make.leading.equalTo(messageImageView.snp.trailing).offset(10)
            make.top.bottom.equalTo(messageImageView)
        }
        addHeadingLabel()
        addSubtitleLabel()
    }
    
    fileprivate func addHeadingLabel() {
        let label = addLabel(text: "New Message")
        label.font = NewCardMessageConstants.titleFont
        theStackView.addArrangedSubview(label)
    }
    
    fileprivate func addSubtitleLabel() {
        let label = addLabel(text: "Tap here to see...")
        label.font = NewCardMessageConstants.subtitleFont
        theStackView.addArrangedSubview(label)
    }
    
    fileprivate func addLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = NewCardMessageConstants.textColor
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
