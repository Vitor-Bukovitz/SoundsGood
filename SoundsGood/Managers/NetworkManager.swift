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

    private let baseUrl = "https://www.googleapis.com/youtube/v3/search?key=\(ApiKeys.youtube)&maxResults=50&part=snippet"
    
    func searchSong(song: String, completed: @escaping (Result<[Song], SGError>)  -> Void) {
        let endpoint = (baseUrl + "&q=\(song)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: endpoint ?? "") else {
            return completed(.failure(.invalidSong))
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
            } catch let e {
                print(e)
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
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
//    
//    func getSong(id: String, completed: @escaping (Result<Data, SGError>) -> Void) {
//        guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") else {
//            return completed(.failure(SGError.defaultError))
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if error != nil {
//                return completed(.failure(SGError.defaultError))
//            }
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                return completed(.failure(SGError.defaultError))
//            }
//            guard let data = data else {
//                return completed(.failure(SGError.defaultError))
//            }
//            
//            completed(.success(data))
//        }.resume()
//    }
}

