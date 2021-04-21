//
//  Song.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import Foundation

enum SongStatus: String, Codable {
    case downloading
    case downloaded
}

struct Song: Codable, Hashable {
    let snippet: Snippet
    let id: String
    var status: SongStatus?
}

struct Snippet: Codable, Hashable {
    let title: String
    let channelTitle: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable, Hashable {
    let high: High
}

struct High: Codable, Hashable {
    let url: String
}

