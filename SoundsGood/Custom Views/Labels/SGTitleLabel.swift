//
//  SGTitleLabel.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import UIKit

class SGTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(textAlign: NSTextAlignment, fontSize: CGFloat) {
        super.init(frame: .zero)
        configure()
        self.textAlignment = textAlign
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 16, weight: .bold)
        numberOfLines = 2
        lineBreakMode = .byTruncatingTail
    }
}
