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
        var episodes: [Episode]
        var previousStart: Int
        var previousEnd: Int
        var nextStart: Int
        var nextEnd: Int
        
        let startNode = req.query?["start"]
        let endNode = req.query?["end"]
        
        if let start = startNode?.int, let end = endNode?.int {
            episodes = try episodeRepository.getEpisodes(start: start, end: end)
            
            if episodes.count <= 0 {
                nextStart = 0
                nextEnd = 0
                previousStart = 0
                previousEnd = 0
            }
            else {
                let delta = abs(start - end)
                if (start < end) { // ascending order
                    nextStart = end > episodes.last!.episodeId ? 0 : end + 1
                    nextEnd = nextStart == 0 ? 0 : nextStart + delta
                    previousEnd = start < episodes.first!.episodeId ? 0 : start - 1
                    previousStart = previousEnd == 0 ? 0 : previousEnd - delta
                }
                else { // start > end, descending order
                    nextStart = end < episodes.last!.episodeId ? 0 : end - 1
                    nextEnd = nextStart == 0 ? 0 : nextStart - delta
                    previousEnd = start > episodes.first!.episodeId ? 0 : start + 1
                    previousStart = previousEnd == 0 ? 0 : previousEnd + delta
                }
            }
        }
        else {
            episodes = try episodeRepository.getLatestEpisodes(25)
            previousStart = 0
            previousEnd = 0
            nextStart = episodes.last!.episodeId - 1
            nextEnd = nextStart - 25
        }
        
        return try view.make("episodes", [
            "episodes": episodes.makeJSON(),
            "previousStart": previousStart,
            "previousEnd": previousEnd,
            "nextStart": nextStart,
            "nextEnd": nextEnd,
        ], for: req)
    }
    
    /// GET /episodes/:id
    func show(_ req: Request, _ episode: Episode) throws -> ResponseRepresentable {
        return try view.make("episode", [
            "episode": episode.makeJSON(),
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
