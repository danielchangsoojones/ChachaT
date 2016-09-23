//
//  EFTableViewController.swift
//  
//
//  Created by Brett Keck on 7/28/15.
//
//

import UIKit


/// This class subclasses UITableViewController.
///
/// The following are important functions to use for cell animations:
///
/// setTranslateDistance(distance : Int)
///
/// - Call this function to change the Translate Distance for a Translate animation.  Default is 50.
///
/// setCellType(cellTypes : Set<CellType>)
///
/// - Call this function to change the cell presentation animation
/// - None: Normal loading of cell, no effects
/// - Translate: Cell slides in from the right, with no alpha fading
/// - Fade: Cell fades in with no motion effect
/// - Scale: Cell scales from a larger or smaller size
/// - Default is [.None]
///
/// setShowType(showType : ShowType)
///
/// - Call this function to change when cells are animated
/// - Always: Every time a cell becomes visible
/// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
/// - Once: The first time a cell becomes visible, does not reset on reload
/// - Default is .Reload
///
/// setDuration(duration : Double)
///
/// - Call this function to change the cell presentation animation time.
/// - Default is 0.4
///
/// setInitialAlpha(alpha : Double)
///
/// - Call this function to change the initial alpha value for any Fade animation.
/// - Ranges from 0.0 to 1.0, defaults to 0.0
///
/// setInitialScale(xscale : Double, yscale : Double)
///
/// - Call this function to change the initial scale value for any Scale animation.
/// - Default is for each is 0.8
///
/// resetCellAnimations()
///
/// - Call this function any time you are reloading your tableView; e.g. when you call tableView.reloadData()

open class EFTableViewController: UITableViewController {
    let efCellAnimation = EFCellAnimation()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Call this function to change the Translate Distance for a Translate animation
    ///
    /// Default is 50
    open func setTranslateDistance(_ distance : Int) {
        efCellAnimation.setTranslateDistance(distance)
    }
    
    /// Call this function to change the cell presentation animation
    ///
    /// - None: Normal loading of cell, no effects
    /// - Translate: Cell slides in from the right, with no alpha fading
    /// - Fade: Cell fades in with no motion effect
    /// - Scale: Cell scales from a larger or smaller size
    ///
    /// Default is [.None]
    open func setCellType(_ cellTypes : Set<CellType>) {
        efCellAnimation.setCellType(cellTypes)
    }
    
    /// Call this function to change when cells are animated
    ///
    /// - Always: Every time a cell becomes visible
    /// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
    /// - Once: The first time a cell becomes visible, does not reset on reload
    ///
    /// Default is .Reload
    open func setShowType(_ showType : ShowType) {
        efCellAnimation.setShowType(showType)
    }
    
    /// Call this function to change the cell presentation animation time
    ///
    /// Default is 0.4
    open func setDuration(_ duration : Double) {
        efCellAnimation.setDuration(duration)
    }
    
    /// Call this function to change the initial alpha value for any Fade animation
    ///
    /// Ranges from 0.0 to 1.0, defaults to 0.0
    open func setInitialAlpha(_ alpha : Double) {
        efCellAnimation.setInitialAlpha(alpha)
    }
    
    /// Call this function to change the initial scale for Scale effects
    ///
    /// Default for each is 0.8
    open func setInitialScale(_ xscale : Double, yscale : Double) {
        efCellAnimation.setInitialScale(xscale, yscale: yscale)
    }
    
    /// This function will need to be called any time a tableview is reloaded UNLESS you don't want the cells to rerun any animations
    open func resetCellAnimations() {
        efCellAnimation.resetPrevIndexes()
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        efCellAnimation.setupAnimation(indexPath, cell: cell)
    }
}
