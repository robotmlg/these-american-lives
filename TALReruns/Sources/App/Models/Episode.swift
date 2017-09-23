//
//  Episode.swift
//  App
//
//  Created by Matt Goldman on 9/20/17.
//

import FluentProvider
import Foundation

final class Episode: Model, Preparation, JSONConvertible, ResponseRepresentable {
    static let entity = "episodes"
    static let idKey = "episode_id"
    let storage = Storage()
    
    // db fields
    var episodeId: Int
    var title: String
    var description: String
    var imageUrl: String
    var episodeUrl: String
    
    // view-only fields
    var tag: String
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        return df
    }()
    
    init() {
        episodeId = 0
        title = ""
        description = ""
        imageUrl = ""
        episodeUrl = ""
        tag = ""
    }
    
    init(row: Row) throws {
        episodeId = try row.get(Episode.idKey)
        title = try row.get("title")
        description = try row.get("description")
        imageUrl = try row.get("image_url")
        episodeUrl = try row.get("episode_url")
        tag = ""
    }
    
    init(json: JSON) throws {
        episodeId = try json.get("episodeId")
        title = try json.get("title")
        description = try json.get("description")
        imageUrl = try json.get("imageUrl")
        episodeUrl = try json.get("episodeUrl")
        tag = try json.get("tag")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Episode.idKey, episodeId)
        try row.set("title", title)
        try row.set("description", description)
        try row.set("image_url", imageUrl)
        try row.set("episode_url", episodeUrl)
        return row
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("episodeId", episodeId)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("imageUrl", imageUrl)
        try json.set("episodeUrl", episodeUrl)
        try json.set("tag", tag)
        
        return json
    }
    
    func setTag(_ tag: String) -> Episode {
        self.tag = tag
        return self
    }
    
    static func prepare(_ database: Database) throws {}
    
    static func revert(_ database: Database) throws {
        throw PreparationError.neverPrepared(Episode.self)
    }
}

