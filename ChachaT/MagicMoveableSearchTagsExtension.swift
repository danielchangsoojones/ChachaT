//
//  MagicMoveableSearchTagsExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension SearchTagsViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: TimeInterval {
        return 0.7
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        let indexPath: IndexPath = theTappedCellIndex
        let collectionViewCell: UserCollectionViewCell = theBottomUserArea?.collectionView.cellForItem(at: indexPath) as! UserCollectionViewCell
        let imageView = collectionViewCell.theImageView
        return [imageView]
    }
}
