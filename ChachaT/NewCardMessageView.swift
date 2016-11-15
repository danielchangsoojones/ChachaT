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
        static let textViewSideInset: CGFloat = 10
    }
    
    var messageImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "PaperAriplane"))
    var theStackView: UIStackView = UIStackView()
    var theSalutationView: MessageSalutationView?
    var theMessageTextView: UITextView?
    var theButtonStackView: UIStackView?
    
    var delegate: NewCardMessageDelegate?
    var swipe: Swipe!
    
    init(frame: CGRect, delegate: NewCardMessageDelegate, swipe: Swipe) {
        super.init(frame: frame)
        self.backgroundColor = CustomColors.SilverChaliceGrey.withAlphaComponent(0.87)
        self.delegate = delegate
        self.swipe = swipe
        makeTappable()
        addMessageImage()
        createStackView()
    }
    
    fileprivate func makeTappable() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMessage(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    func showMessage(sender: UITapGestureRecognizer? = nil) {
        animateShowingMessage()
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

//showing the message
extension NewCardMessageView {
    fileprivate func animateShowingMessage() {
        UIView.animate(withDuration: 0.3, animations: {
            self.hideNewMessageComponents()
        }, completion: { (complete: Bool) in
            self.animateGrowth()
        })
    }
    
    fileprivate func animateGrowth() {
        UIView.animate(withDuration: 0.7, animations: {
            if let superview = self.superview {
                self.frame = superview.bounds
            }
        }, completion: { (complete: Bool) in
            self.gestureRecognizers?.removeAll()
            self.addShowMessageComponents()
        })
    }
    
    func hideNewMessageComponents() {
        theStackView.alpha = 0
        messageImageView.alpha = 0
    }
    
    fileprivate func addShowMessageComponents() {
        addSalutationView()
        addBottomButtonStackView()
        addTextView()
    }
    
    fileprivate func addSalutationView() {
        let otherUser = swipe.otherUser
        theSalutationView = MessageSalutationView(name: otherUser.firstName ?? "" , profileImage: otherUser.profileImage, beginsWithTo: false)
        theSalutationView?.setTextColor(color: NewCardMessageConstants.textColor)
        self.addSubview(theSalutationView!)
        theSalutationView?.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(NewCardMessageConstants.textViewSideInset)
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    fileprivate func addBottomButtonStackView() {
        theButtonStackView = UIStackView()
        theButtonStackView?.axis = .horizontal
        theButtonStackView?.distribution = .fillEqually
        theButtonStackView?.spacing = 10
        theButtonStackView?.alignment = .fill
        self.addSubview(theButtonStackView!)
        theButtonStackView?.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.75)
            make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let deleteButton = createBottomButton(title: "Delete")
        let respondButton = createBottomButton(title: "Respond")
        theButtonStackView?.addArrangedSubview(deleteButton)
        theButtonStackView?.addArrangedSubview(respondButton)
    }
    
    fileprivate func createBottomButton(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitleColor(CustomColors.JellyTeal, for: .normal)
        button.setCornerRadius(radius: 15)
        button.setTitle(title, for: .normal)
        return button
    }
    
    fileprivate func addTextView() {
        theMessageTextView = UITextView()
        theMessageTextView?.text = "hiisidididlskd"
        theMessageTextView?.textColor = NewCardMessageConstants.textColor
        theMessageTextView?.isUserInteractionEnabled = false
        theMessageTextView?.backgroundColor = UIColor.clear
        self.addSubview(theMessageTextView!)
        theMessageTextView?.snp.makeConstraints({ (make) in
            make.leading.equalTo(theSalutationView!)
            make.trailing.equalTo(self).inset(NewCardMessageConstants.textViewSideInset)
            make.top.equalTo(theSalutationView!.snp.bottom)
            make.bottom.equalTo(theButtonStackView!.snp.top)
        })
    }
    
    
}
