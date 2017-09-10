//
//  Airing.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

import FluentProvider
import Foundation

final class Airing: Model, Preparation, JSONRepresentable {
    static let entity = "all_airings"
    let storage = Storage()
    
    // db fields
    var episodeId: Int
    var title: String
    var description: String
    var imageUrl: String
    var episodeUrl: String
    var originalAirDate: Date
    var airDate: Date
    
    // view-only fields
    var tag: String
    
    static let formatter = DateFormatter()
        
    init(row: Row) throws {
        episodeId = try row.get("episode_id")
        title = try row.get("title")
        description = try row.get("description")
        imageUrl = try row.get("image_url")
        episodeUrl = try row.get("episode_url")
        originalAirDate = try row.get("original_air_date")
        airDate = try row.get("air_date")
        tag = ""
    }
    
    func makeRow() throws -> Row {
        return Row();
    }
    
    func makeJSON() throws -> JSON {
        Airing.formatter.dateStyle = .long
        
        var json = JSON()
        
        try json.set("episodeId", episodeId)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("imageUrl", imageUrl)
        try json.set("episodeUrl", episodeUrl)
        try json.set("originalAirDate", Airing.formatter.string(from: originalAirDate))
        try json.set("airDate", Airing.formatter.string(from: airDate))
        try json.set("tag", tag)
        
        return json
    }
    
    func setTag(_ tag: String) -> Airing {
        self.tag = tag
        return self
    }
    
    static func prepare(_ database: Database) throws {}

    static func revert(_ database: Database) throws {
        throw PreparationError.neverPrepared(Airing.self)
    }
}
