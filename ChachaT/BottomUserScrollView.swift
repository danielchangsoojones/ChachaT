//
//  BottomUserScrollView.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class BottomUserScrollView: UIView {
    fileprivate struct BottomViewConstants {
        static let backgroundColor: UIColor = UIColor.white
        static let topLineColor: UIColor = CustomColors.SilverChaliceGrey
        static let lineHeight: CGFloat = 1.0
        static let lineAlpha: CGFloat = 0.5
    }
    
    //using swipes instead of users because we want to be able to push swipes to the card, so when we have buttons on the card for swiping when on the cardDetailPage, we will be able to do that.
    var swipes: [Swipe] = []
    var delegate: BottomUserScrollViewDelegate?
    var collectionView: UICollectionView!
    
    init(swipes: [Swipe], frame: CGRect, delegate: BottomUserScrollViewDelegate) {
        super.init(frame: frame)
        self.swipes = swipes
        self.delegate = delegate
        collectionViewSetup()
        topLineSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func topLineSetup() {
        let line = UIView()
        line.backgroundColor = BottomViewConstants.topLineColor
        line.alpha = BottomViewConstants.lineAlpha
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.trailing.top.leading.equalTo(self)
            make.height.equalTo(BottomViewConstants.lineHeight)
        }
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
        collectionView.backgroundColor = BottomViewConstants.backgroundColor
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
    }
    
    fileprivate func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: self.frame.height, height: self.frame.height)
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentSwipe = swipes[indexPath.row]
        self.delegate?.segueToCardDetailPage(swipe: currentSwipe, tappedIndex: indexPath)
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
        return cell
    }
}

protocol BottomUserScrollViewDelegate {
    func segueToCardDetailPage(swipe: Swipe, tappedIndex: IndexPath)
}

extension SearchTagsViewController: BottomUserScrollViewDelegate {
    func segueToCardDetailPage(swipe: Swipe, tappedIndex: IndexPath) {
        let cardDetailVC = UIStoryboard(name: Storyboards.main.storyboard, bundle: nil).instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController
        theTappedCellIndex = tappedIndex
        cardDetailVC.userOfTheCard = swipe.otherUser
        presentViewControllerMagically(self, to: cardDetailVC, animated: true, duration: duration, spring: spring)
    }
}
