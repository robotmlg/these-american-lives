//
//  Airing.swift
//  App
//
//  Created by Matt Goldman on 9/20/17.
//

import FluentProvider
import Foundation

final class Airing: Model, Preparation, JSONConvertible, ResponseRepresentable, Comparable {
    static let entity = "airings"
    static let idKey = "airing_id"
    let storage = Storage()
    
    // db fields
    var airingId: Int
    var episodeId: Int
    var airDate: Date
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        return df
    }()
    
    init() {
        airingId = 0
        episodeId = 0
        airDate = Date()
    }
    
    init(row: Row) throws {
        airingId = try row.get("airing_id")
        episodeId = try row.get("episode_id")
        airDate = try row.get("air_date")
    }
    
    init(json: JSON) throws {
        airingId = try json.get("airingId")
        episodeId = try json.get("episodeId")
        airDate = try Airing.formatter.date(from: json.get("airDate"))!
    }
    
    static func <(lhs: Airing, rhs: Airing) -> Bool{
        return lhs.airDate < rhs.airDate
    }
    
    static func ==(lhs: Airing, rhs: Airing) -> Bool{
        return lhs.episodeId == rhs.episodeId && lhs.airDate == rhs.airDate
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("airing_id", airingId)
        try row.set("episode_id", episodeId)
        try row.set("air_date", airDate)
        return row
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("airingId", airingId)
        try json.set("episodeId", episodeId)
        try json.set("airDate", Airing.formatter.string(from: airDate))
        
        return json
    }
    
    static func prepare(_ database: Database) throws {}
    
    static func revert(_ database: Database) throws {
        throw PreparationError.neverPrepared(Airing.self)
    }
}
