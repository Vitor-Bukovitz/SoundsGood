//
//  Song.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import Foundation

struct Song: Codable {
    let snippet: Snippet
    let id: Id
}

struct Snippet: Codable {
    let title: String
    let channelTitle: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let high: High
}

struct High: Codable {
    let url: String
}

struct Id: Codable {
    let videoId: String?
}
