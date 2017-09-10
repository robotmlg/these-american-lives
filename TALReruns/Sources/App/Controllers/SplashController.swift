import Vapor
import HTTP

//
//  SplashController.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

final class SplashController {
    let view: ViewRenderer
    let episodeRepository: EpisodeRepository
    
    init(_ view: ViewRenderer) {
        self.view = view
        episodeRepository = EpisodeRepository()
    }
    
    func getSplashData(_ req: Request) throws -> ResponseRepresentable {
        var latestEpisodes = try episodeRepository.getLatestAirings(3)
        
        // reorder episodes to This Week - Last Week - Next Week
        var orderedEpisodes = [Airing]()
        orderedEpisodes.append(latestEpisodes[1].setTag("THIS WEEK"))
        orderedEpisodes.append(latestEpisodes[0].setTag("LAST WEEK"))
        orderedEpisodes.append(latestEpisodes[2].setTag("NEXT WEEK"))
        
        return try view.make("splash", [
            "episodes": orderedEpisodes.makeJSON(),
            ], for: req)
    }
}

