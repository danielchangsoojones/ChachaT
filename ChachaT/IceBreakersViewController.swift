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
        static let newCellAlpha: CGFloat = 0.6
        static let newCellColor: UIColor = CustomColors.SilverChaliceGrey
        static let newCellText: String = "Add a new ice breaker..."
        static let fontSize: CGFloat = 20
    }
    
    
    var theTableView: UITableView!
    
    var iceBreakers: [IceBreaker] = []
    var dataStore: IceBreakerDataStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        dataStoreSetup()
        rightBarButtonSetup()
        titleViewSetup()
        self.navigationController?.navigationBar.tintColor = UIColor.white
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
    
    fileprivate func dataStoreSetup() {
        self.dataStore = IceBreakerDataStore(delegate: self)
    }
}

extension IceBreakersViewController {
    fileprivate func rightBarButtonSetup() {
        createRightBarButtonItem(systemItem: .edit)
    }
    
    fileprivate func createRightBarButtonItem(systemItem: UIBarButtonSystemItem) {
        let button = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(makeTableViewEditable(sender:)))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    fileprivate func titleViewSetup() {
        self.navigationBarColor = CustomColors.JellyTeal
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
        createRightBarButtonItem(systemItem: systemItem)
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
            cell.detailTextLabel?.text = iceBreakers[row].text
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: IceBreakersConstants.fontSize)
            return cell
        }
    }
    
    fileprivate func createPlaceholderCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.detailTextLabel?.text = IceBreakersConstants.newCellText
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: IceBreakersConstants.fontSize)
        cell.detailTextLabel?.textColor = IceBreakersConstants.newCellColor
        cell.detailTextLabel?.alpha = IceBreakersConstants.newCellAlpha
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataStore.delete(iceBreaker: iceBreakers[indexPath.row])
            iceBreakers.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
        let newIceBreakVC = NewIceBreakerViewController(iceBreaker: iceBreakers[indexPath.row])
        newIceBreakVC.delegate = self
        pushVC(newIceBreakVC)
    }
}

extension IceBreakersViewController: NewIceBreakerControllerDelegate {
    func passUpdated(iceBreaker: IceBreaker) {
        if let tappedIndexPath = theTableView.indexPathForSelectedRow {
            let row = tappedIndexPath.row
            if row == 0 {
                //tapped the create new ice breaker
                iceBreakers.insert(iceBreaker, at: 1)
            } else {
                iceBreakers[tappedIndexPath.row] = iceBreaker
            }
            theTableView.reloadData()
        }
    }
}

extension IceBreakersViewController: IceBreakerDataStoreDelegate {
    func passCurrentUser(iceBreakers: [IceBreaker]) {
        self.iceBreakers = iceBreakers
        let placeholderIceBreaker = IceBreaker()
        self.iceBreakers.insertAsFirst(placeholderIceBreaker)
        theTableView.reloadData()
    }
}
