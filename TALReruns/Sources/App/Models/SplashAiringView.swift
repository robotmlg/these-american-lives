//
//  SplashAiringView.swift
//  App
//
//  Created by Matt Goldman on 10/14/17.
//

import Foundation

final class SplashAiringView:JSONRepresentable, Comparable {

    var episodeId: Int
    var title: String
    var description: String
    var imageUrl: String
    var episodeUrl: String
    var originalAirDate: Date
    var previousAirDate: Date
    var airDate: Date
    var tag: String

    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateStyle = .long
        return df
    }()

    init() {
        episodeId = 0
        title = ""
        description = ""
        imageUrl = ""
        episodeUrl = ""
        originalAirDate = Date()
        airDate = Date()
        previousAirDate = Date()
        tag = ""
    }

    init(_ airing: AiringView) {
        episodeId = airing.episodeId
        title = airing.title
        description = airing.description
        imageUrl = airing.imageUrl
        episodeUrl = airing.episodeUrl
        originalAirDate = airing.originalAirDate
        airDate = airing.airDate
        previousAirDate = airing.airDate
        tag = airing.tag
    }

    static func <(lhs: SplashAiringView, rhs: SplashAiringView) -> Bool {
        return lhs.airDate < rhs.airDate
    }

    static func ==(lhs: SplashAiringView, rhs: SplashAiringView) -> Bool {
        return lhs.episodeId == rhs.episodeId &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.imageUrl == rhs.imageUrl &&
            lhs.episodeUrl == rhs.episodeUrl &&
            lhs.originalAirDate == rhs.originalAirDate &&
            lhs.airDate == rhs.airDate &&
            lhs.tag == rhs.tag
    }

    func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set("episodeId", episodeId)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("imageUrl", imageUrl)
        try json.set("episodeUrl", episodeUrl)
        try json.set("originalAirDate", AiringView.formatter.string(from: originalAirDate))
        try json.set("previousAirDate", AiringView.formatter.string(from: previousAirDate))
        try json.set("airDate", AiringView.formatter.string(from: airDate))
        try json.set("tag", tag)

        return json
    }

    func setTag(_ tag: String) -> SplashAiringView {
        self.tag = tag
        return self
    }
}

