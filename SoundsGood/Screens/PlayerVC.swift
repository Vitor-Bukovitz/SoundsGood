//
//  PlayerVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/29/21.
//

import UIKit
import CoreMedia

protocol PlayerVCDelegate: AnyObject {
    func didDismiss()
}

class PlayerVC: UIViewController {

    private let topImageView = UIView()
    private let topImage = SGImageView(frame: .zero)
    private let titleLabel = SGTitleLabel(textAlign: .left, fontSize: 18)
    private let authorLabel = SGBodyLabel()
    private let currentTimeLabel = SGBodyLabel()
    private let durationTimeLabel = SGBodyLabel()
    private let slider = UISlider()
    private let playButton = SGButton(type: .pause)
    private let skipButton = SGButton(type: .skip)
    private let previousButton = SGButton(type: .previous)
    
    private var song: Song?
    weak var delegate: PlayerVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureLayout()
        sliderObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didDismiss()
    }

    private func configureViewController() {
        view.backgroundColor = .white
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }

    func setSong(song: Song) {
        self.song = song
        titleLabel.text = song.snippet.title
        authorLabel.text = song.snippet.channelTitle
        topImage.setRemoteImage(url: song.snippet.thumbnails.high.url)
    }
    
    private func configureLayout() {
        view.addSubview(topImageView)
        view.addSubview(topImage)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(slider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationTimeLabel)
        view.addSubview(playButton)
        view.addSubview(skipButton)
        view.addSubview(previousButton)
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 1
        slider.tintColor = Colors.purpleColor
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "00:00"
        durationTimeLabel.textAlignment = .right
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonPressed), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonPressed), for: .touchUpInside)

        let padding: CGFloat = 18
        NSLayoutConstraint.activate([
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 68),
            playButton.widthAnchor.constraint(equalToConstant: 68),
            
            previousButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -32),
            previousButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 34),
            previousButton.widthAnchor.constraint(equalToConstant: 34),
            
            skipButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 32),
            skipButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 34),
            skipButton.widthAnchor.constraint(equalToConstant: 34),
            
            slider.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -36),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            slider.heightAnchor.constraint(equalToConstant: 12),
            
            currentTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: padding),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            currentTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: padding),
            
            durationTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: padding),
            durationTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            durationTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            durationTimeLabel.heightAnchor.constraint(equalToConstant: padding),
            
            titleLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -36),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: padding),
            
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            topImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor,constant: -80),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            
            topImage.centerYAnchor.constraint(equalTo: topImageView.centerYAnchor),
            topImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            topImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            topImage.heightAnchor.constraint(equalTo: topImage.widthAnchor),
        ])
    }
    
    @objc private func playButtonPressed() {
        if SongManager.player?.timeControlStatus == .playing {
            SongManager.player?.pause()
        } else {
            SongManager.player?.play()
        }
        setButtons()
    }
    
    @objc private func previousButtonPressed() {
        guard let song = SongManager.playPrevious() else { return }
        presentSong(song: song)
    }
    
    @objc private func skipButtonPressed() {
        guard let song = SongManager.playNext() else { return }
        presentSong(song: song)
    }
    
    private func presentSong(song: Song) {
        let pvc = self.presentingViewController
        let destVC = PlayerVC()
        destVC.setSong(song: song)
        let navController = UINavigationController(rootViewController: destVC)
        dismiss(animated: true) {
            pvc?.present(navController, animated: true)
        }
    }
    
    
    private func sliderObserver() {
        slider.addAction(UIAction(handler: onSliderTouched), for: .touchDown)
        slider.addAction(UIAction(handler: onSliderEnd), for: .touchUpInside)
        slider.addAction(UIAction(handler: onSliderChanged), for: .valueChanged)
        SongManager.delegate = self
        SongManager.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: .max), queue: DispatchQueue.main, using: { time in
            self.setButtons()
            let currentSeconds = SongManager.currentSeconds()
            let totalSeconds = SongManager.totalSeconds()
            self.slider.setValue(Float((round(currentSeconds) / round(totalSeconds))), animated: true)
            
            self.currentTimeLabel.text = currentSeconds.asString(style: .positional)
            self.durationTimeLabel.text = totalSeconds.asString(style: .positional)
        })
    }
    
    private func setButtons() {
        if SongManager.player?.timeControlStatus == .playing {
            playButton.toggleIcon(to: .pause)
        } else {
            playButton.toggleIcon(to: .play)
        }
        skipButton.isEnabled = SongManager.canPlayNext()
        previousButton.isEnabled = SongManager.canPlayPrevious()
    }
    
    private func onSliderTouched(action: UIAction) {
        SongManager.player?.pause()
    }

    private func onSliderEnd(action: UIAction) {
        let totalSeconds = SongManager.totalSeconds()
        SongManager.player?.currentItem?.seek(to: CMTime(seconds: round(totalSeconds * Double(slider.value)), preferredTimescale: .max), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: nil)
        SongManager.player?.play()
    }
    
    private func onSliderChanged(action: UIAction) {
        let totalSeconds = SongManager.totalSeconds()
        let selectedSeconds = round(totalSeconds * Double(slider.value))
        self.currentTimeLabel.text = selectedSeconds.asString(style: .positional)
    }
    
    private enum NumberType {
        case seconds
        case minutes
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

extension PlayerVC: SongManagerDelegate {
    
    func onNextSong(nextSong: Song) {
        presentSong(song: nextSong)
    }
}
