//
//  UIViewController+Ext.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/28/21.
//

import UIKit

extension UIViewController {
    func presentAlertOnMainThread(title: String, message: String) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alertVC, animated: true)
        }
    }
}
