//
//  SongManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/29/21.
//

import Foundation
import AVKit
import MediaPlayer

protocol SongManagerDelegate: AnyObject {
    func onNextSong(nextSong: Song)
}

enum SongManager {
    static private let baseUrl = "https://vitorbukovitz.pythonanywhere.com/song/"
    static var player: AVPlayer?
    static var songs: [Song]?
    static var properties: [String: Any]?
    static private var currentIndex = 0
    
    static weak var delegate: SongManagerDelegate?

    static func playSong(index: Int) {
        guard let songs = songs else { return }
        let currentSong = songs[index]
        currentIndex = index
    
        let localUrl = LocalStorageManager.getLocalSongURL(song: currentSong)
        if let localUrl = localUrl {
            player = AVPlayer(url: localUrl)
        } else {
            guard let videoId = currentSong.id.videoId else { return }
            guard let url = URL(string: baseUrl + videoId) else { return }
            player = AVPlayer(url: url)
        }
        player?.volume = 1.0
        player?.play()
        automaticallyPlayNext()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        NetworkManager.shared.downloadImage(from: currentSong.snippet.thumbnails.medium.url) { image in
            updateBackgroundStatus()
            if let image = image {
                properties = [
                    MPMediaItemPropertyArtist: currentSong.snippet.channelTitle,
                    MPMediaItemPropertyTitle: currentSong.snippet.title,
                    MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
                        return image
                    }
                ]
            } else {
                #warning("set placehodler image")
            }
        }
        setCommands(index: index)
    }
    
    static func getCurrentSong() -> Song? {
        guard player != nil else { return nil }
        return songs?[currentIndex]
    }
    
    static func playNext() -> Song? {
        guard currentIndex + 1 < songs?.count ?? 0 else { return nil }
        playSong(index: currentIndex + 1)
        return songs?[currentIndex + 1]
    }
    
    static func playPrevious() -> Song? {
        guard currentIndex - 1 > 0 else { return nil }
        playSong(index: currentIndex - 1)
        return songs?[currentIndex - 1]
    }
    
    static func canPlayPrevious() -> Bool {
        let commandCenter = MPRemoteCommandCenter.shared()
        return commandCenter.previousTrackCommand.isEnabled
    }
    static func canPlayNext() -> Bool {
        let commandCenter = MPRemoteCommandCenter.shared()
        return commandCenter.nextTrackCommand.isEnabled
    }
    
    static func currentSeconds() -> Double {
        player?.currentTime().seconds ?? 0
    }
    
    static func totalSeconds() -> Double {
        let result = (player?.currentItem?.duration.seconds ?? 1) / 2
        return result > 0 ? result : 1
    }
    
    static func configurePlayer(songs: [Song]) {
        self.songs = songs
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player?.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            if let player = self.player {
               let playerRate = player.rate
               if let event = event as? MPChangePlaybackPositionCommandEvent {
                   player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { success in
                       if success {
                           self.player?.rate = playerRate
                       }
                   })
                   return .success
                }
            }
            return .commandFailed
        }
    }
    
    private static func updateBackgroundStatus() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard var properties = properties else { return }
            properties[MPMediaItemPropertyPlaybackDuration] = totalSeconds()
            properties[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentSeconds()
            properties[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate ?? 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = properties
        }
    }
    
    private static func setCommands(index: Int) {
        guard let songs = songs else { return }
        let commandCenter = MPRemoteCommandCenter.shared()

        let nextSong = (index + 1) < songs.count ? songs[index + 1] : nil
        commandCenter.nextTrackCommand.isEnabled = nextSong != nil
        commandCenter.nextTrackCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard (index + 1) < songs.count else { return .success }
            playSong(index: index + 1)
            return .success
        }
        
        let previousSong = (index - 1) >= 0 ? songs[index - 1] : nil
        commandCenter.previousTrackCommand.isEnabled = previousSong != nil
        commandCenter.previousTrackCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard (index - 1) >= 0 else { return .success }
            playSong(index: index - 1)
            return .success
        }
    }
    
    private static func automaticallyPlayNext() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: .max), queue: DispatchQueue.main, using: { time in
            let currentSeconds = self.currentSeconds()
            let totalSeconds = self.totalSeconds()
            if currentSeconds > totalSeconds {
                guard let song = playNext() else { return }
                delegate?.onNextSong(nextSong: song)
            }
        })
    }
}
