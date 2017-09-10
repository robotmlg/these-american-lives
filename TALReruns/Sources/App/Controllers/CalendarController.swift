import Vapor
import HTTP

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
    
    init(_ view: ViewRenderer) {
        self.view = view
        episodeRepository = EpisodeRepository()
    }
    
    /// GET /calendar
    func index(_ req: Request) throws -> ResponseRepresentable {
        let latestAirings = try episodeRepository.getLatestAirings(25)
        
        return try view.make("calendar", [
            "episodes": latestAirings.makeJSON(),
            ], for: req)
    }
    
    func makeResource() -> Resource<Airing> {
        return Resource(
            index: index
        )
    }
}

