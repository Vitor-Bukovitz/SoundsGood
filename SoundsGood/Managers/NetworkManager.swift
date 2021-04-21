//
//  NetworkManager.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/28/21.
//

import UIKit

protocol NetworkManagerDelegate: AnyObject {
    func didDownloadedSong(for id: String)
}

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    let cache = NSCache<NSString, UIImage>()
    weak var delegate: NetworkManagerDelegate?
    private let baseURL = "https://yt-download.org/api/button/mp3/"
    private let youtubeURL = "https://www.googleapis.com/youtube/v3/videos?part=id%2C+snippet&key=AIzaSyBqQUruaUmZ45EJGcYxs2M71yLw6uZjEpw&id="
    
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
    
    func downloadSong(for youtubeURL: String, with downloadURL: URL, completed: @escaping (SGError?) -> Void) {
        guard let id = getIdFromYoutubeURL(url: youtubeURL) else { return completed(.invalidData) }
        guard let songURL = URL(string: self.youtubeURL + id) else { return completed(.invalidSong) }

        URLSession.shared.dataTask(with: songURL) { data, response, error in
            guard error == nil else { return completed(.invalidData) }
            guard let data = data else { return completed(.invalidData) }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return completed(.invalidResponse) }
            
            do {
                let decoder = JSONDecoder()
                let youtubeResult = try decoder.decode(YoutubeResult.self, from: data)
                guard var song = youtubeResult.items.first else { return completed(.invalidData) }
                song.status = .downloading
                LocalStorageManager.updateWithSong(song: song, actionType: .add) { _ in
                    self.downloadSongMp3(with: downloadURL, for: id)
                }
                completed(nil)
            } catch {
                completed(.invalidData)
            }
        }.resume()
    }
    
    func canDownload(video url: String, completed: @escaping (String?) -> Void) {
        LocalStorageManager.retrieveSongs { result in
            switch result {
            case .success(let songs):
                guard let id = self.getIdFromYoutubeURL(url: url) else { return completed(nil) }
                if songs.contains(where: { $0.id == id }) {
                    completed(nil)
                } else {
                    
                    guard let url = URL(string: self.baseURL + id) else { return completed(nil) }
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                        if let _ = error { return completed(nil) }
                        guard let data = data else { return completed(nil) }
                        do {
                            let text = String(decoding: data, as: UTF8.self)
                            let regex = try NSRegularExpression(pattern: #"(?<=href=").*?(?=")"#)
                            let results = regex.matches(in: text,
                                                        range: NSRange(text.startIndex..., in: text))
                            if results.count > 1 {
                                guard let last = results.last else { return completed(nil) }
                                guard let range = Range(last.range, in: text) else { return completed(nil) }
                                let downloadURL = String(text[range])
                                completed(downloadURL)
                            } else {
                                completed(nil)
                            }
                        } catch {
                            completed(nil)
                        }
                    }).resume()
                }
            case .failure(_):
                completed(nil)
            }
        }
    }
    
    private func downloadSongMp3(with downloadURL: URL, for id: String) {
        URLSession.shared.downloadTask(with: downloadURL) { (location, urlResponse, error) in
            if let _ = error { return }
            guard let location = location else { return }
            let destPath = self.getDirectory(for: "\(id).mp3")
            try? FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: destPath))
            self.delegate?.didDownloadedSong(for: id)
        }.resume()
    }
    
    private func getIdFromYoutubeURL(url: String) -> String? {
        let range = NSRange(location: 0, length: url.utf16.count)
        let regex = try? NSRegularExpression(pattern: "(?<=v=)(.*)")
        guard let result = regex?.firstMatch(in: url, options: [], range: range) else { return nil }
        return (url as NSString).substring(with: result.range)
    }
    
    private func getDirectory(for file: String) -> String {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first else { return "" }
        let destPath = NSString(string: documentPath).appendingPathComponent(file) as String
        return destPath
    }
}
