//
//  SGButton.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 4/10/21.
//

import UIKit

enum SGButtonType {
    case play
    case skip
    case previous
}

class SGButton: UIButton {
    
    init(type: SGButtonType) {
        super.init(frame: .zero)
        configure(type)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(_ type: SGButtonType) {
        switch type {
        case .play:
            imageView?.image = UIImage.playIcon
        case .skip:
            imageView?.image = UIImage.skipIcon
        case .previous:
            imageView?.image = UIImage.previousIcon
        }
    }
}
