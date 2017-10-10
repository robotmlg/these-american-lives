//
//  Episode.swift
//  App
//
//  Created by Matt Goldman on 9/20/17.
//

import FluentProvider
import Foundation

final class Episode: Model, Preparation, JSONRepresentable, ResponseRepresentable {
    static let entity = "episodes"
    let storage = Storage()
    
    // db fields
    var title: String
    var description: String
    var imageUrl: String
    var episodeUrl: String
    
    // view-only fields
    var tag: String
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateStyle = .long
        return df
    }()
    
    init() {
        title = ""
        description = ""
        imageUrl = ""
        episodeUrl = ""
        tag = ""
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        description = try row.get("description")
        imageUrl = try row.get("image_url")
        episodeUrl = try row.get("episode_url")
        tag = ""
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("description", description)
        try row.set("image_url", imageUrl)
        try row.set("episode_url", episodeUrl)
        return row
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("episodeId", id)
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
    
    static func prepare(_ database: Database) throws {
        try database.raw("""
            CREATE TABLE IF NOT EXISTS episodes(
                id INTEGER PRIMARY KEY
                , title VARCHAR(256) NOT NULL
                , description TEXT NOT NULL
                , image_url VARCHAR(512) NOT NULL
                , episode_url VARCHAR(512) NOT NULL
            );
        """)
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

