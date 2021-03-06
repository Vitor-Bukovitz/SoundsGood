//
//  UIImage+Ext.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 4/10/21.
//

import UIKit

extension UIImage {
    
    open class var searchIcon: UIImage? {
        return UIImage(named: "search-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var menuIcon: UIImage? {
        return UIImage(named: "menu-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var playIcon: UIImage? {
        return UIImage(named: "play-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var pauseIcon: UIImage? {
        return UIImage(named: "pause-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var skipIcon: UIImage? {
        return UIImage(named: "skip-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var previousIcon: UIImage? {
        return UIImage(named: "previous-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var downloadIcon: UIImage? {
        return UIImage(named: "download-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var downloadedIcon: UIImage? {
        return UIImage(named: "downloaded-icon")?.withRenderingMode(.alwaysOriginal)
    }
    
    open class var placeholderImage: UIImage? {
        return UIImage(named: "placeholder-image")
    }
}
