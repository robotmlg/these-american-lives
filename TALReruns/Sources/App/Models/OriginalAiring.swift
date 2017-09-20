//
//  Episode.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/10/17.
//
//

import FluentProvider
import Foundation

final class OriginalAiring: Model, Preparation, JSONConvertible, ResponseRepresentable {
    static let entity = "original_airings"
    static let idKey = "episode_id"
    let storage = Storage()
    
    // db fields
    var episodeId: Int
    var title: String
    var description: String
    var imageUrl: String
    var episodeUrl: String
    var originalAirDate: Date
    
    // view-only fields
    var tag: String
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        return df
    }()
    
    init(row: Row) throws {
        episodeId = try row.get("episode_id")
        title = try row.get("title")
        description = try row.get("description")
        imageUrl = try row.get("image_url")
        episodeUrl = try row.get("episode_url")
        originalAirDate = try row.get("original_air_date")
        tag = ""
    }
    
    init(json: JSON) throws {
        episodeId = try json.get("episodeId")
        title = try json.get("title")
        description = try json.get("description")
        imageUrl = try json.get("imageUrl")
        episodeUrl = try json.get("episodeUrl")
        originalAirDate = try OriginalAiring.formatter.date(from: json.get("originalAirDate"))!
        tag = try json.get("tag")
    }
    
    func makeRow() throws -> Row {
        return Row();
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("episodeId", episodeId)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("imageUrl", imageUrl)
        try json.set("episodeUrl", episodeUrl)
        try json.set("originalAirDate", OriginalAiring.formatter.string(from: originalAirDate))
        try json.set("tag", tag)
        
        return json
    }
    
    func setTag(_ tag: String) -> OriginalAiring {
        self.tag = tag
        return self
    }
    
    static func prepare(_ database: Database) throws {}
    
    static func revert(_ database: Database) throws {
        throw PreparationError.neverPrepared(OriginalAiring.self)
    }
}
