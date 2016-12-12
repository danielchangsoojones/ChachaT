//
//  IceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class IceBreakersViewController: UIViewController {
    fileprivate struct IceBreakersConstants {
        static let placeholderAlpha: CGFloat = 0.6
        static let placeholderColor: UIColor = CustomColors.SilverChaliceGrey
        static let placeHolderText: String = "i.e. what is your favorite color?"
        static let fontSize: CGFloat = 20
    }
    
    var iceBreakers: [String] = [IceBreakersConstants.placeHolderText, "hii", "butttholio"]
    var theTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        rightBarButtonSetup()
        titleViewSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func viewSetup() {
        let iceBreakersView = IceBreakersView(frame: self.view.bounds)
        theTableView = iceBreakersView.theTableView
        iceBreakersView.theTableView.dataSource = self
        iceBreakersView.theTableView.delegate = self
        self.view.addSubview(iceBreakersView)
    }
}

extension IceBreakersViewController {
    fileprivate func rightBarButtonSetup() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(makeTableViewEditable(sender:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    fileprivate func titleViewSetup() {
        let titleView = UIView(frame: CGRect(x: 0,y: 0,w: 100,h: 40))
        let titleLabel = addTitleLabel()
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        let iceBreakerSymbol = lightningBoltSetup()
        titleView.addSubview(iceBreakerSymbol)
        iceBreakerSymbol.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
        }
        self.navigationItem.titleView = titleView
    }
    
    fileprivate func questionButtonSetup() -> UIButton {
        //TODO: make thuis an actual lightning bolt as the image
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "LightningBolt"), for: .normal)
        button.addTarget(self, action: #selector(infoIndicatorPressed(sender:)), for: .touchUpInside)
        return button
    }
    
    func infoIndicatorPressed(sender: UIButton) {
        print("info indi pressed")
    }
    
    fileprivate func lightningBoltSetup() -> UIImageView {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "LightningBolt"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    fileprivate func addTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Ice Breakers"
        return titleLabel
    }
    
    @objc fileprivate func makeTableViewEditable(sender: UIBarButtonItem) {
        //TODO: toggle the title to done
        var systemItem: UIBarButtonSystemItem = .edit
        if (self.theTableView.isEditing) {
            systemItem = .edit
            self.theTableView.setEditing(false, animated: true)
        } else {
            systemItem = .done
            self.theTableView.setEditing(true, animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(makeTableViewEditable(sender:)))
    }
}

extension IceBreakersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iceBreakers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            return createPlaceholderCell()
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.detailTextLabel?.text = iceBreakers[row]
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: IceBreakersConstants.fontSize)
            return cell
        }
    }
    
    fileprivate func createPlaceholderCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.detailTextLabel?.text = IceBreakersConstants.placeHolderText
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: IceBreakersConstants.fontSize)
        cell.detailTextLabel?.textColor = IceBreakersConstants.placeholderColor
        cell.detailTextLabel?.alpha = IceBreakersConstants.placeholderAlpha
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            iceBreakers.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension IceBreakersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 0 {
            //can't remove placeholder cell
            return .none
        } else {
            if (self.theTableView.isEditing) {
                return UITableViewCellEditingStyle.delete
            }
            
            return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newIceBreakVC = NewIceBreakerViewController()
        pushVC(newIceBreakVC)
    }
}
