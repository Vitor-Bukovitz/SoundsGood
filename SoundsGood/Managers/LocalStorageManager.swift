//
//  LocalStorageManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import Foundation

enum LocalStorageActionType {
    case add, remove
}

enum LocalStorageManager {

    static private let defaults = UserDefaults.standard

    private enum Keys {
        static let songs = "songs"
    }
    
    static func updateWithSong(song: Song, actionType: LocalStorageActionType, completed: @escaping (SGError?) -> Void) {
        retrieveSongs { result in
            switch result {
            case .success(let songs):
                var retrieveSongs = songs
                switch actionType {
                case .add:
                    guard !retrieveSongs.contains(song) else {
                        return completed(SGError.alreadySaved)
                    }
                    retrieveSongs.append(song)
                case .remove:
                    retrieveSongs.removeAll {$0.id.videoId == song.id.videoId}
                }
                completed(saveSongs(song: retrieveSongs))
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveSongs(completed: @escaping (Result<[Song], SGError>) -> Void) {
        guard let songsData = defaults.object(forKey: Keys.songs) as? Data else { return completed(.success([])) }
        do {
            let decoder = JSONDecoder()
            let songs = try decoder.decode([Song].self, from: songsData)
            completed(.success(songs))
        } catch let e {
            print(e)
            completed(.failure(.defaultError))
        }
    }
    
    private static func saveSongs(song: [Song]) -> SGError? {
        do {
            let encoder = JSONEncoder()
            let encondedSong = try encoder.encode(song)
            defaults.set(encondedSong, forKey: Keys.songs)
            return nil
        } catch {
            return SGError.unableToSave
        }
    }
}
