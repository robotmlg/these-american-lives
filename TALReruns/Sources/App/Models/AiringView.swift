//
//  Airing.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

import FluentProvider
import Foundation

final class AiringView: Model, Preparation, JSONRepresentable, Comparable {
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
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
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
        airDate = try row.get("air_date")
        tag = ""
    }
    
    init() {
        episodeId = 0
        title = ""
        description = ""
        imageUrl = ""
        episodeUrl = ""
        originalAirDate = Date()
        airDate = Date()
        tag = ""
    }
    
    static func <(lhs: AiringView, rhs: AiringView) -> Bool {
        return lhs.airDate < rhs.airDate
    }
    
    static func ==(lhs: AiringView, rhs: AiringView) -> Bool {
        return lhs.episodeId == rhs.episodeId &&
               lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.imageUrl == rhs.imageUrl &&
               lhs.episodeUrl == rhs.episodeUrl &&
               lhs.originalAirDate == rhs.originalAirDate &&
               lhs.airDate == rhs.airDate &&
               lhs.tag == rhs.tag
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
        try json.set("originalAirDate", AiringView.formatter.string(from: originalAirDate))
        try json.set("airDate", AiringView.formatter.string(from: airDate))
        try json.set("tag", tag)
        
        return json
    }
    
    func setTag(_ tag: String) -> AiringView {
        self.tag = tag
        return self
    }
    
    static func prepare(_ database: Database) throws {}

    static func revert(_ database: Database) throws {
        throw PreparationError.neverPrepared(AiringView.self)
    }
}
