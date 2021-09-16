//
//  ApiResponce.swift
//  MusicAppForHedgehog
//
//  Created by Михаил Серёгин on 19.08.2021.
//

import Foundation

struct APIResponse: Codable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Codable {
    let collectionName: String
    let artworkUrl100: String
    let artistName: String
    let collectionId: Int
    let trackName: String?
    let country: String
    let primaryGenreName: String
    let releaseDate: String
}
