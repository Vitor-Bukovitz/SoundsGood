//
//  PlayerVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/29/21.
//

import UIKit
import CoreMedia

class PlayerVC: UIViewController {

    private let topImage = SGImageView(frame: .zero)
    private let titleLabel = SGTitleLabel(textAlign: .left, fontSize: 18)
    private let authorLabel = SGBodyLabel()
    private let currentTimeLabel = SGBodyLabel()
    private let durationTimeLabel = SGBodyLabel()
    private let slider = UISlider()
    private let playButton = SGButton(type: .pause)
    private let skipButton = SGButton(type: .skip)
    private let previousButton = SGButton(type: .previous)
    private let downloadButton = SGButton(type: .download)
    private let activityIndicator = UIActivityIndicatorView()
    
    private var song: Song?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureDownloadButton()
        configureLayout()
        sliderObserver()
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
        topImage.setRemoteImage(url: song.snippet.thumbnails.medium.url)
    }
    
    private func configureLayout() {
        view.addSubview(topImage)
        view.addSubview(titleLabel)
        view.addSubview(downloadButton)
        view.addSubview(authorLabel)
        view.addSubview(slider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationTimeLabel)
        view.addSubview(playButton)
        view.addSubview(skipButton)
        view.addSubview(previousButton)
        downloadButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 1
        slider.tintColor = Colors.purpleColor
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "00:00"
        durationTimeLabel.textAlignment = .right
        activityIndicator.color = Colors.purpleColor
        activityIndicator.hidesWhenStopped = true
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonPressed), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonPressed), for: .touchUpInside)

        
        NSLayoutConstraint.activate([
            topImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            topImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topImage.heightAnchor.constraint(equalToConstant: 220),
            topImage.widthAnchor.constraint(equalToConstant: 220),
            
            downloadButton.topAnchor.constraint(equalTo: topImage.bottomAnchor, constant: 18),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            downloadButton.widthAnchor.constraint(equalToConstant: 34),
            downloadButton.heightAnchor.constraint(equalToConstant: 34),
            
            titleLabel.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -18),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            slider.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 36),
            slider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            slider.heightAnchor.constraint(equalToConstant: 12),
            
            currentTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 18),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            currentTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 18),
            
            durationTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 18),
            durationTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            durationTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            durationTimeLabel.heightAnchor.constraint(equalToConstant: 18),
            
            
            playButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 18),
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
            
            activityIndicator.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: downloadButton.heightAnchor),
            activityIndicator.widthAnchor.constraint(equalTo: downloadButton.heightAnchor),
        ])
    }
    
    private func configureDownloadButton() {
        LocalStorageManager.retrieveSongs { [weak self] result in
            guard let self = self else { return }
            guard let song = self.song else { return }
            switch result {
            case .success(let songs):
                if songs.contains(song) {
                    self.downloadButton.toggleIcon(to: .downloaded)
                }
            default:
                return
            }
        }
    }
    
    @objc private func downloadButtonPressed() {
        guard let song = song else { return }
        downloadButton.setImage(UIImage(), for: .normal)
        activityIndicator.startAnimating()
        LocalStorageManager.retrieveSongs { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let songs):
                if songs.contains(song) {
                    let ac = UIAlertController(title: "Delete song?", message: "Are you sure you want to delete this song?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: self.deleteSong))
                    ac.addAction(UIAlertAction(title: "No", style: .cancel))
                    DispatchQueue.main.async {
                        self.present(ac, animated: true)
                    }
                } else {
                    NetworkManager.shared.downloadSong(song: song) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.downloadButton.toggleIcon(to: .downloaded)
                            }
                            self.presentAlertOnMainThread(title: "Sucess", message: "Song saved successfully 🎉")
                        case .failure(let error):
                            self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
                        }
                    }
                }
            default:
                return
            }
        }
    }
    
    @objc private func deleteSong(_ sender: UIAlertAction) {
        guard let song = song else { return }
        LocalStorageManager.updateWithSong(song: song, actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlertOnMainThread(title: "Something went wrong", message: error.rawValue)
            } else {
                self.dismiss(animated: true)
            }
        }
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
            
            let currentSecondsText = self.formatNumber(value: currentSeconds, type: .seconds)
            let currentMinutesText = self.formatNumber(value: currentSeconds, type: .minutes)
            self.currentTimeLabel.text = "\(currentMinutesText):\(currentSecondsText)"
            
            
            let totalSecondsText = self.formatNumber(value: totalSeconds, type: .seconds)
            let totalMinutesText = self.formatNumber(value: totalSeconds, type: .minutes)
            self.durationTimeLabel.text = "\(totalMinutesText):\(totalSecondsText)"
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
        let currentSecondsText = formatNumber(value: selectedSeconds, type: .seconds)
        let currentMinutesText = formatNumber(value: selectedSeconds, type: .minutes)
        self.currentTimeLabel.text = "\(currentMinutesText):\(currentSecondsText)"
    }
    
    private enum NumberType {
        case seconds
        case minutes
    }
    
    private func formatNumber(value: Double, type: NumberType) -> String {
        var roundedValue: Double = 00
        switch type {
        case .seconds:
            roundedValue = round(Double(Int(value) % 60))
        case .minutes:
            roundedValue = round(Double(Int(value / 60) % 60))
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        let formattedAmount = formatter.string(from: roundedValue as NSNumber)
        return String(formattedAmount ?? "00")
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
