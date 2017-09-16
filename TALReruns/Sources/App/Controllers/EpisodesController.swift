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
    
    /// GET /episodes/:id
    func show(_ req: Request, _ episode: Episode) throws -> ResponseRepresentable {
        
        let e = try episode.makeJSON()
        
        return try view.make("episode", [
            "episode": e,
            "next": episode.episodeId + 1,
            "previous": episode.episodeId - 1,
        ], for: req)
    }
    
    func makeResource() -> Resource<Episode> {
        return Resource(
            index: index,
            show: show
        )
    }
}
