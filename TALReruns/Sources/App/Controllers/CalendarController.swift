import Vapor
import HTTP
import Foundation

//
//  CalendarController.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

final class CalendarController : ResourceRepresentable{
    let view: ViewRenderer
    let episodeRepository: EpisodeRepository
    
    init(_ view: ViewRenderer, repo: EpisodeRepository) {
        self.view = view
        episodeRepository = repo
    }
    
    static let oneDay: Double = 86400
    static let oneWeek: Double = oneDay * 7
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyyMMdd"
        return df
    }()
    
    /// GET /calendar
    func index(_ req: Request) throws -> ResponseRepresentable {
        var episodes: [AiringView]
        var previousStart: Date!
        var previousEnd: Date!
        var nextStart: Date!
        var nextEnd: Date!
        
        let startNode = req.query?["start"]
        let endNode = req.query?["end"]
        
        let startString = startNode?.string
        let endString = endNode?.string

        let calendar = NSCalendar.current

        if startString != nil && endString != nil {
            guard let start = dateFormatter.date(from: startString!) else { return try view.make("calendar", [], for: req) }
            guard let end   = dateFormatter.date(from: endString!)   else { return try view.make("calendar", [], for: req) }
            
            episodes = try episodeRepository.getAirings(start: start, end: end)
            
            if episodes.count <= 0 {
                nextStart = Date()
                nextEnd = Date()
                previousStart = Date()
                previousEnd = Date()
            }
            else {
                let startTime = calendar.startOfDay(for: start)
                let endTime = calendar.startOfDay(for: end)
                let delta = abs(Double(calendar.dateComponents([.day], from: startTime, to: endTime).day!)) * CalendarController.oneDay
                if (start < end) { // ascending order
                    if end > Date() {
                        nextStart = Date()
                        nextEnd = Date()
                    }
                    else {
                        nextStart = end + CalendarController.oneDay
                        nextEnd = nextStart + delta
                    }
                    previousEnd = start - CalendarController.oneDay
                    previousStart = previousEnd - delta
                }
                else { // start > end, descending order
                    nextStart = end - CalendarController.oneDay
                    nextEnd = nextStart - delta

                    if start > Date() {
                        previousStart = Date()
                        previousEnd = Date()
                    }
                    else {
                        previousEnd = start + CalendarController.oneDay
                        previousStart = previousEnd + delta
                    }
                }
            }
        }
        else {
            episodes = try episodeRepository.getLatestAirings(25)
            let startTime = calendar.startOfDay(for: episodes.last!.airDate)
            let endTime = calendar.startOfDay(for: episodes.first!.airDate)
            let delta = abs(Double(calendar.dateComponents([.day], from: startTime, to: endTime).day!)) * CalendarController.oneDay
            previousStart = Date()
            previousEnd = Date()
            nextStart = episodes.last!.airDate - CalendarController.oneDay
            nextEnd = nextStart! - delta
        }

        return try view.make("calendar", [
            "episodes": episodes.makeJSON(),
            "previousStart": dateFormatter.string(from: previousStart),
            "previousEnd":  dateFormatter.string(from: previousEnd),
            "nextStart":  dateFormatter.string(from: nextStart),
            "nextEnd":  dateFormatter.string(from: nextEnd),
            ], for: req)
    }
    
    func makeResource() -> Resource<AiringView> {
        return Resource(
            index: index
        )
    }
}

