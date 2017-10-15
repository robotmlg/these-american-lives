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
    let episodeRepo: EpisodeRepository
    
    init(_ view: ViewRenderer, repo: EpisodeRepository) {
        self.view = view
        episodeRepo = repo
    }
    
    func getSplashData(_ req: Request) throws -> ResponseRepresentable {
        let latestAirings = try episodeRepo.getLatestAirings(3)
        let splashAirings = latestAirings.map{(x: AiringView) -> SplashAiringView in return SplashAiringView(x)}

        let episodeIds: [Int] = latestAirings.map{(x: AiringView) -> Int in return x.episodeId}
        let allAirings = try episodeRepo.getAiringsForEpisodes(episodeIds).sorted().reversed()

        // Maybe worth implementing some sort of multimap here, but probably not
        // Iterating over the list should be plenty fast
        for airing in splashAirings {
            var count = 0
            for a in allAirings {
                if a.episodeId == airing.episodeId {
                    count += 1
                    if count == 2 {
                        airing.previousAirDate = a.airDate
                        break
                    }
                }
            }
        }
        
        // reorder episodes to This Week - Last Week - Next Week
        var orderedEpisodes = [SplashAiringView]()
        orderedEpisodes.append(splashAirings[1].setTag("THIS WEEK"))
        orderedEpisodes.append(splashAirings[2].setTag("LAST WEEK"))
        orderedEpisodes.append(splashAirings[0].setTag("NEXT WEEK"))
        
        return try view.make("splash", [
            "episodes": orderedEpisodes.makeJSON(),
            ], for: req)
    }
}

