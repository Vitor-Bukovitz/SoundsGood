//
//  NetworkManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/28/21.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    let cache = NSCache<NSString, UIImage>()

    private let apiBaseUrl = "https://vitorbukovitz.pythonanywhere.com/song/"
    private let baseUrl = "https://www.googleapis.com/youtube/v3/search?key=\(ApiKeys.youtube)&maxResults=50&part=snippet"
    
    func searchSong(song: String, completed: @escaping (Result<[Song], SGError>)  -> Void) {
        let endpoint = (baseUrl + "&q=\(song)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: endpoint ?? "") else {
            return completed(.failure(.invalidSong))
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                return completed (.failure(.unableToComplete))
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return completed(.failure(.invalidResponse))
            }
            
            guard let data = data else {
                return completed(.failure(.invalidData))
            }
            
            do {
                let decoder = JSONDecoder()
                var youtubeResult = try decoder.decode(YoutubeResult.self, from: data)
                youtubeResult.items.removeAll { $0.id.videoId == nil }
                completed(.success(youtubeResult.items))
            } catch {
                completed(.failure(.invalidData))
            }
        }.resume()
    }
    
    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
        }
        
        guard let url = URL(string: urlString) else {
            return completed(nil)
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil { return completed(nil) }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return completed(nil) }
            guard let data = data else { return completed(nil) }
            
            guard let image = UIImage(data: data) else { return completed(nil) }
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(image)
        }.resume()
    }
    
    func downloadSong(song: Song, completed: @escaping (Result<URL, SGError>) -> Void) {
        guard let videoid = song.id.videoId else { return completed(.failure(SGError.invalidData)) }
        
        let endpoint = apiBaseUrl + videoid
        guard let url = URL(string: endpoint) else { return completed(.failure(.invalidSong)) }
        
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first else { return }
        let destPath = NSString(string: documentPath).appendingPathComponent("\(videoid).mp4") as String
        if FileManager.default.fileExists(atPath: destPath) { return completed(.success(URL(fileURLWithPath: destPath))) }
        
        URLSession.shared.downloadTask(with: url, completionHandler: { location, urlResponse, error in
            if let _ = error { return completed (.failure(.unableToComplete)) }
            guard let location = location else { return completed(.failure(SGError.invalidResponse))}
            do {
                try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: destPath))
                LocalStorageManager.updateWithSong(song: song, actionType: .add) { error in
                    if let error = error { completed(.failure(error)) }
                    completed(.success(URL(fileURLWithPath: destPath)))
                }
            } catch {
                completed(.failure(.invalidData))
            }
        }).resume()
    }
    
    func getLocalSongURL(song: Song) -> URL? {
        guard let videoid = song.id.videoId else { return nil }
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first else { return nil }
        let destPath = NSString(string: documentPath).appendingPathComponent("\(videoid).mp4") as String
        if FileManager.default.fileExists(atPath: destPath) {
            return URL(fileURLWithPath: destPath)
        }
        return nil
    }
}

