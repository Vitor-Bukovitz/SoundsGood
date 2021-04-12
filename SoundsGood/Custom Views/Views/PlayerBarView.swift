//
//  PlayerBarView.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 4/11/21.
//

import UIKit
import CoreMedia

class PlayerBarView: UIView {
    
    private let titleLabel = SGBodyLabel()
    private let playButton = SGButton(type: .pause)
    private let skipButton = SGButton(type: .skip)
    private let previousButton = SGButton(type: .previous)
    
    weak var controller: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        addSubview(titleLabel)
        addSubview(playButton)
        addSubview(skipButton)
        addSubview(previousButton)
        
        clipsToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.6
        layer.shadowColor = Colors.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        backgroundColor = Colors.whiteColor
        translatesAutoresizingMaskIntoConstraints = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerTapped)))
        isHidden = true
        
        titleLabel.numberOfLines = 1
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonPressed), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            
            skipButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            skipButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 20),
            skipButton.widthAnchor.constraint(equalToConstant: 20),
            
            playButton.trailingAnchor.constraint(equalTo: skipButton.leadingAnchor, constant: -18),
            playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 38),
            playButton.heightAnchor.constraint(equalToConstant: 38),
            
            previousButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -18),
            previousButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 20),
            previousButton.widthAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func configureObserver() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let song = SongManager.getCurrentSong() else {
                self.isHidden = true
                return
            }
            self.isHidden = false
            self.titleLabel.text = song.snippet.title
            self.setButtons()
        }
    }
    
    private func setButtons(forcePlayingButton: Bool? = nil) {
        if forcePlayingButton != nil {
            if forcePlayingButton == true {
                playButton.toggleIcon(to: .play)
            } else {
                playButton.toggleIcon(to: .pause)
            }
            return
        } else if SongManager.player?.timeControlStatus == .playing {
            playButton.toggleIcon(to: .pause)
        } else {
            playButton.toggleIcon(to: .play)
        }
        skipButton.isEnabled = SongManager.canPlayNext()
        previousButton.isEnabled = SongManager.canPlayPrevious()
    }
    
    @objc private func playButtonPressed() {
        if SongManager.player?.timeControlStatus == .playing {
            SongManager.player?.pause()
            setButtons(forcePlayingButton: false)
        } else {
            SongManager.player?.play()
            setButtons(forcePlayingButton: true)
        }
    }
    
    @objc func playerTapped() {
        guard let song = SongManager.getCurrentSong() else{ return }
        let destVC = PlayerVC()
        destVC.setSong(song: song)
        let navControlelr = UINavigationController(rootViewController: destVC)
        controller?.navigationController?.present(navControlelr, animated: true)
    }
    
    @objc private func previousButtonPressed() {
        let _ = SongManager.playPrevious()
    }
    
    @objc private func skipButtonPressed() {
        let _ = SongManager.playNext()
    }
}
