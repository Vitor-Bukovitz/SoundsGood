//
//  Double+Ext.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 4/16/21.
//

import Foundation

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    if self > 3600 {
        formatter.allowedUnits = [.hour, .minute, .second]
    } else {
        formatter.allowedUnits = [.minute, .second]
    }
    formatter.unitsStyle = style
    formatter.zeroFormattingBehavior = .pad
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
