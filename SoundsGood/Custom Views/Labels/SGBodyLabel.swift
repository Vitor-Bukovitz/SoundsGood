//
//  SGBodyLabel.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import UIKit

class SGBodyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lineBreakMode = .byTruncatingTail
    }

}
