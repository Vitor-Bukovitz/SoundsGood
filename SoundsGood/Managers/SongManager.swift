//
//  SongManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/29/21.
//

import Foundation
import AVKit
import MediaPlayer

enum SongManager {
    static var player: AVPlayer?
    static var songs: [Song]?

    static func playSong(index: Int) {
        guard let songs = songs else { return }
        let currentSong = songs[index]
        
        guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") else { return }
        player = AVPlayer(url: url)
        player?.volume = 1.0
        player?.play()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: currentSong.snippet.title]
        setCommands(index: index)
    }
    
    static func configurePlayer(songs: [Song]) {
        self.songs = songs
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player?.pause()
            return .success
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
}
