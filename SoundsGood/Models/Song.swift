//
//  Song.swift
//  SoundsGood
//
//  Created by Vitor Bukovitz on 3/27/21.
//

import Foundation

struct Song: Codable, Hashable {
    let snippet: Snippet
    let id: Id
}

struct Snippet: Codable, Hashable {
    let title: String
    let channelTitle: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable, Hashable {
    let medium: Medium
}

struct Medium: Codable, Hashable {
    let url: String
}

struct Id: Codable, Hashable {
    let videoId: String?
}
