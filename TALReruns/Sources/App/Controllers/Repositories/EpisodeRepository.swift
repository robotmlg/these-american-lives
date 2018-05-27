//
//  EpisodeRepository.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

import Foundation

final class EpisodeRepository {

    func getLatestAirings(_ count: Int) throws -> [AiringView] {
        return try AiringView.makeQuery()
                         .sort("air_date", .descending)
                         .limit(count)
                         .all()
    }
    
    func getAirings(start: Date, end: Date) throws -> [AiringView] {
        if start == end{
            return try [getAiring(start)]
        }
        else if start < end {
            return try AiringView.makeQuery()
                .filter("air_date", .greaterThanOrEquals, start)
                .filter("air_date", .lessThanOrEquals, end)
                .sort("air_date", .ascending)
                .all()
        }
        else { // start > end
            return try AiringView.makeQuery()
                .filter("air_date", .greaterThanOrEquals, end)
                .filter("air_date", .lessThanOrEquals, start)
                .sort("air_date", .descending)
                .all()
        }
    }
    
    func getAiring(_ date: Date) throws -> AiringView {
        guard let airing = try AiringView.makeQuery()
                                     .filter("air_date", .equals, date)
                                     .first()
            else { throw Abort.notFound }
        return airing
    }
    
    func getAiringsForEpisode(_ episodeId: Int) throws -> [AiringView] {
        return try AiringView.makeQuery()
                                .filter("episode_id", .equals, episodeId)
                                .all()
    }

    func getAiringsForEpisodes(_ episodeIds: [Int]) throws -> [AiringView] {
        return try AiringView.makeQuery()
                             .filter("episode_id", in: episodeIds)
                             .all()
    }
    
    func getLatestEpisodes(_ count: Int) throws -> [OriginalAiring] {
        let episodes = try OriginalAiring.makeQuery()
                                  .sort("episode_id", .descending)
                                  .limit(count)
                                  .all()
        return episodes
    }
    
    func getEpisodes(start: Int, end: Int) throws -> [OriginalAiring] {
        if start == end{
            return try [getEpisode(start)]
        }
        else if start < end {
            return try OriginalAiring.makeQuery()
                              .filter("episode_id", .greaterThanOrEquals, start)
                              .filter("episode_id", .lessThanOrEquals, end)
                              .sort("episode_id", .ascending)
                              .all()
        }
        else { // start > end
            return try OriginalAiring.makeQuery()
                              .filter("episode_id", .greaterThanOrEquals, end)
                              .filter("episode_id", .lessThanOrEquals, start)
                              .sort("episode_id", .descending)
                              .all()
        }
    }
    
    func getEpisode(_ id: Int) throws -> OriginalAiring {
        guard let episode = try OriginalAiring.find(id) else { throw Abort.notFound }
        return episode
    }

    func getSimilarEpisodes(_ episode: OriginalAiring) throws -> [OriginalAiring] {
        let titleParts = episode.title.split(separator: " ")

        if titleParts.count == 1 {
            return []
        }

        let titleMatch = titleParts.dropLast().joined(separator: " ") + "%"

        return try OriginalAiring.makeQuery()
            .filter("title", .custom("LIKE"), titleMatch)
            .filter("title", .notEquals, episode.title)
            .sort("original_air_date", .descending)
            .all()
    }
}
