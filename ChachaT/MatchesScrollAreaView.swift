//
//  MatchesScrollAreaView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class MatchesScrollAreaView: UIView {
    private struct MatchesScrollConstants {
        static let circleViewSize : CGSize = CGSize(width: 20, height: 20)
    }
    
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file.
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var theStackView: UIStackView!
    var scrollView : UIScrollView = UIScrollView(frame: CGRect(x: 0,y: 0,width: 600, height: 100))
    var contentView : UIView = UIView()
    var stackView : UIStackView = UIStackView()
    
    init() {
        super.init(frame: CGRectZero)
        addScrollView()
    }
    
    func addScrollView() {
        self.addSubview(scrollView)
        scrollView.backgroundColor = UIColor.blueColor()
        addContentView()
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addContentView() {
        scrollView.addSubview(contentView)
        contentView.backgroundColor = UIColor.redColor()
        addStackView()
        contentView.snp_makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(self)
        }
    }
    
    func addStackView() {
        contentView.addSubview(stackView)
        addLabel()
        stackView.snp_makeConstraints { (make) in
            make.leading.top.bottom.trailing.equalTo(contentView)
        }
    }

    func addLabel() {
        let label = UILabel()
        label.text = "butthole5"
        let labelf = UILabel()
        labelf.text = "butthole7"
        let labelg = UILabel()
        labelg.text = "butthole7jaklsdjfalsdjfl;ad asdkjfas;jdfklsajdf dsalkjflasjdf;lkas saldkjfasdljfkl;asjdfkl; salkdjfl;asjk"
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(labelg)
        stackView.addArrangedSubview(labelf)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        //this name must match the nib file name
        NSBundle.mainBundle().loadNibNamed("MatchesScrollAreaView", owner: self, options: nil)[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    func addMatchView(name: String, imageFile: AnyObject) {
        let circleProfileView = CircleProfileView(name: name, circleViewSize: MatchesScrollConstants.circleViewSize, imageFile: imageFile)
        stackView.addArrangedSubview(circleProfileView)
    }

}
