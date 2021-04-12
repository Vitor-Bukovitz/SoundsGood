//
//  SGButton.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 4/10/21.
//

import UIKit

enum SGButtonType {
    case play
    case pause
    case skip
    case previous
    case download
    case downloaded
}

class SGButton: UIButton {
    
    convenience init(type: SGButtonType) {
        self.init(type: .system)
        configure(type)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(_ type: SGButtonType) {
        translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .play:
            setImage(UIImage.playIcon, for: .normal)
        case .pause:
            setImage(UIImage.pauseIcon, for: .normal)
        case .skip:
            setImage(UIImage.skipIcon, for: .normal)
        case .previous:
            setImage(UIImage.previousIcon, for: .normal)
        case .download:
            setImage(UIImage.downloadIcon, for: .normal)
        case .downloaded:
            setImage(UIImage.downloadedIcon, for: .normal)
        }
    }
    
    func toggleIcon(to type: SGButtonType) {
        configure(type)
    }
    
    func checkIsDownloaded(song: Song) {
        
    }
}
