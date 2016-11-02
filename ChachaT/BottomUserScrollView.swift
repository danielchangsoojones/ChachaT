//
//  BottomUserScrollView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class BottomUserScrollView: UIView {
    var swipes: [Swipe] = []
    var collectionView: UICollectionView!
    
    init(swipes: [Swipe], frame: CGRect) {
        super.init(frame: frame)
        self.swipes = swipes
        collectionViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(newData: [Swipe]) {
        self.swipes = newData
        collectionView.reloadData()
    }
}

extension BottomUserScrollView: UICollectionViewDelegate {
    fileprivate func collectionViewSetup() {
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: createCollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.yellow
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
    }
    
    fileprivate func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.frame.width / 3, height: self.frame.height)
        return layout
    }
}

extension BottomUserScrollView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return swipes.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        cell.theUser = swipes[indexPath.row].otherUser
        cell.backgroundColor = UIColor.red
        return cell
    }
}
