//
//  PlayerVC.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/29/21.
//

import UIKit
import CoreMedia

class PlayerVC: UIViewController {

    let topImage = SGImageView(frame: .zero)
    let titleLabel = SGTitleLabel(textAlign: .left, fontSize: 18)
    let authorLabel = SGBodyLabel()
    let currentTimeLabel = SGBodyLabel()
    let durationTimeLabel = SGBodyLabel()
    let slider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureLayout()
        sliderObserver()
    }

    private func configureViewController() {
        view.backgroundColor = .white
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }

    func setSong(song: Song) {
        titleLabel.text = song.snippet.title
        authorLabel.text = song.snippet.channelTitle
        topImage.setRemoteImage(url: song.snippet.thumbnails.high.url)
    }
    
    private func configureLayout() {
        view.addSubview(topImage)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(slider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationTimeLabel)

        titleLabel.numberOfLines = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = Colors.purpleColor
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "00:00"
        durationTimeLabel.textAlignment = .right

        
        NSLayoutConstraint.activate([
            topImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            topImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topImage.heightAnchor.constraint(equalToConstant: 220),
            topImage.widthAnchor.constraint(equalToConstant: 220),
            
            titleLabel.topAnchor.constraint(equalTo: topImage.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
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
        ])
    }
    
    private func sliderObserver() {
        slider.addAction(UIAction(handler: onSliderTouched), for: .touchDown)
        slider.addAction(UIAction(handler: onSliderEnd), for: .touchUpInside)
        slider.addAction(UIAction(handler: onSliderChanged), for: .valueChanged)
        SongManager.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: .max), queue: DispatchQueue.main, using: { time in
            let currentSeconds = SongManager.player?.currentTime().seconds ?? 0
            guard let totalSeconds = SongManager.player?.currentItem?.duration.seconds, totalSeconds >= 0 else { return }
            self.slider.setValue(Float((round(currentSeconds) / round(totalSeconds))), animated: true)
            
            let currentSecondsText = self.formatNumber(value: currentSeconds, type: .seconds)
            let currentMinutesText = self.formatNumber(value: currentSeconds, type: .minutes)
            self.currentTimeLabel.text = "\(currentMinutesText):\(currentSecondsText)"
            
            
            let totalSecondsText = self.formatNumber(value: totalSeconds, type: .seconds)
            let totalMinutesText = self.formatNumber(value: totalSeconds, type: .minutes)
            self.durationTimeLabel.text = "\(totalMinutesText):\(totalSecondsText)"
        })
    }
    
    private func onSliderTouched(action: UIAction) {
        SongManager.player?.pause()
    }

    private func onSliderEnd(action: UIAction) {
        guard let totalSeconds = SongManager.player?.currentItem?.duration.seconds, totalSeconds >= 0 else { return }
        SongManager.player?.currentItem?.seek(to: CMTime(seconds: round(totalSeconds * Double(slider.value)), preferredTimescale: .max), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: nil)
        SongManager.player?.play()
    }
    
    private func onSliderChanged(action: UIAction) {
        guard let totalSeconds = SongManager.player?.currentItem?.duration.seconds, totalSeconds >= 0 else { return }
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
