//
//  LocalStorageManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import Foundation

enum LocalStorageManager {

    static private let defaults = UserDefaults.standard

    private enum Keys {
        static let songs = "songs"
    }
    
    static func retrieveSongs(completed: @escaping (Result<[Song], SGError>) -> Void) {
        guard let favoritesData = defaults.object(forKey: Keys.songs) as? Data else {
            return completed(.success([]))
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Song].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.defaultError))
        }
    }
}
