//
//  EFCellAnimation.swift
//  
//
//  Created by Brett Keck on 7/28/15.
//
//

import UIKit


/// Type for how the cell is presented on first load
///
/// - None: Normal loading of cell, no effects
/// - Translate: Cell slides in from the right, with no alpha fading
/// - Fade: Cell fades in with no motion effect
/// - Scale: Cell scales from a larger or smaller size
public enum CellType : Int {
    case none
    case translate
    case fade
    case scale
}

/// Type for when a cell is animated
///
/// - Always: Every time a cell becomes visible
/// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
/// - Once: The first time a cell becomes visible, does not reset on reload
public enum ShowType {
    case always, reload, once
}

class EFCellAnimation {
    /// How far the cell will travel on a Translate effect
    ///
    /// Default is 50
    fileprivate var TRANSLATE_DISTANCE : CGFloat = 50
    
    /// Type of cell presentation
    ///
    /// Default is [.None]
    fileprivate var CELL_TYPE : Set<CellType> = [CellType.none]
    
    /// When to show animations
    ///
    /// Default is .Reload
    fileprivate var SHOW_TYPE = ShowType.reload
    
    /// Duration for all effects
    ///
    /// Default is 0.4
    fileprivate var DURATION = 0.4
    
    /// Initial scale for ScaleIn and ScaleOut effects
    ///
    /// Default is 0.8
    fileprivate var INITIAL_X_SCALE = 0.8
    fileprivate var INITIAL_Y_SCALE = 0.8
    
    /// Initial alpha for Fade effects
    ///
    /// Ranges from 0.0 to 1.0, defaults to 0.0
    fileprivate var INITIAL_ALPHA : Float = 0.0
    
    fileprivate var translateTransform : CATransform3D!
    fileprivate var scaleTransform : CATransform3D!
    
    fileprivate var prevIndexes : Set<IndexPath> = []
    
    init() {
        translateTransform = CATransform3DTranslate(CATransform3DIdentity, TRANSLATE_DISTANCE, 0, 0)
        scaleTransform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0)
    }
    
    func setTranslateDistance(_ distance : Int) {
        TRANSLATE_DISTANCE = CGFloat(distance)
        translateTransform = CATransform3DTranslate(CATransform3DIdentity, TRANSLATE_DISTANCE, 0, 0)
    }
    
    func setCellType(_ cellTypes : Set<CellType>) {
        CELL_TYPE = cellTypes
    }
    
    func setShowType(_ showType : ShowType) {
        SHOW_TYPE = showType
    }
    
    func setDuration(_ duration : Double) {
        DURATION = duration
    }
    
    func setInitialScale(_ xscale : Double, yscale : Double) {
        INITIAL_X_SCALE = xscale
        INITIAL_Y_SCALE = yscale
        scaleTransform = CATransform3DScale(CATransform3DIdentity, CGFloat(xscale), CGFloat(yscale), 1)
    }
    
    func setInitialAlpha(_ alpha : Double) {
        INITIAL_ALPHA = Float(alpha)
    }
    
    func resetPrevIndexes() {
        if SHOW_TYPE != .once {
            prevIndexes = []
        }
    }
    
    //TODO: Readme file - CocoaPods 0.38 required?
    
    func setupAnimation(_ indexPath: IndexPath, cell: UITableViewCell) {
        if !prevIndexes.contains(indexPath) || SHOW_TYPE == .always {
            prevIndexes.insert(indexPath)
            let content = cell.contentView
            if CELL_TYPE.contains(.translate) {
                content.layer.transform = translateTransform
            }
            if CELL_TYPE.contains(.fade) {
                content.layer.opacity = INITIAL_ALPHA
            }
            if CELL_TYPE.contains(.scale) {
                content.layer.transform = scaleTransform
            }
            
            UIView.animate(withDuration: DURATION, animations: { () -> Void in
                content.layer.transform = CATransform3DIdentity
                content.layer.opacity = 1.0
            })
        }
    }
}
