//
//  EpisodesController.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/10/17.
//
//

import Vapor
import HTTP

final class EpisodesController : ResourceRepresentable{
    let view: ViewRenderer
    let episodeRepository: EpisodeRepository
    
    init(_ view: ViewRenderer) {
        self.view = view
        episodeRepository = EpisodeRepository()
    }
    
    /// GET /episodes
    func index(_ req: Request) throws -> ResponseRepresentable {
        let latestEpisodes = try episodeRepository.getLatestEpisodes(25)
        
        return try view.make("episodes", [
            "episodes": latestEpisodes.makeJSON(),
            ], for: req)
    }
    
    func makeResource() -> Resource<Episode> {
        return Resource(
            index: index
        )
    }
}
