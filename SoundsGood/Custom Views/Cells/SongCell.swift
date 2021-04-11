//
//  SongCell.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import UIKit

class SongCell: UITableViewCell {
    
    static let reuseID = "SongCell"
    private let titleLabel = SGTitleLabel()
    private let authorLabel = SGBodyLabel()
    private let leadingImage = SGImageView(frame: .zero)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(song: Song) {
        titleLabel.text = song.snippet.title
        authorLabel.text = song.snippet.channelTitle
        leadingImage.setRemoteImage(url: song.snippet.thumbnails.high.url)
    }
    
    private func configure() {
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(leadingImage)
        selectionStyle = .none
        
        let outerPadding: CGFloat = 24
        let innerPadding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            leadingImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: outerPadding),
            leadingImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leadingImage.heightAnchor.constraint(equalToConstant: 35),
            leadingImage.widthAnchor.constraint(equalToConstant: 35),
            
            titleLabel.topAnchor.constraint(equalTo: leadingImage.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingImage.trailingAnchor, constant: innerPadding),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: leadingImage.trailingAnchor, constant: innerPadding),
            authorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: leadingImage.bottomAnchor),
        ])
    }

}
