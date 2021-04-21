//
//  SongCell.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import UIKit

class SongCell: UITableViewCell {
    
    static let reuseID = "SongCell"
    private let leadingImage = SGImageView(frame: .zero)
    private let loadingIndicator = UIActivityIndicatorView()
    private let titleLabel = SGTitleLabel()
    private let authorLabel = SGBodyLabel()
    
    
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
        
        switch song.status {
        case .downloaded:
            loadingIndicator.stopAnimating()
            leadingImage.isHidden = false
            titleLabel.textColor = .black
            authorLabel.textColor = .black
            backgroundColor = .clear
        default:
            loadingIndicator.startAnimating()
            leadingImage.isHidden = true
            titleLabel.textColor = .secondaryLabel
            authorLabel.textColor = .tertiaryLabel
            backgroundColor = .systemGray6
        }
    }
    
    private func configure() {
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(leadingImage)
        addSubview(loadingIndicator)
        selectionStyle = .none
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = Colors.purpleColor
        
        let outerPadding: CGFloat = 24
        let innerPadding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            leadingImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: outerPadding),
            leadingImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leadingImage.heightAnchor.constraint(equalToConstant: 35),
            leadingImage.widthAnchor.constraint(equalToConstant: 35),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: leadingImage.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: leadingImage.centerXAnchor),
            loadingIndicator.heightAnchor.constraint(equalTo: leadingImage.heightAnchor),
            loadingIndicator.widthAnchor.constraint(equalTo: leadingImage.widthAnchor),
            
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
