//
//  EpisodeRepository.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

final class EpisodeRepository {
    
    func getLatestAirings(_ count: Int) throws -> [Airing] {
        return try Airing.makeQuery()
                         .sort("air_date", .descending)
                         .limit(count)
                         .all()
    }
    
    func getAirings(start: Date, end: Date) throws -> [Airing] {
        if start == end{
            return try [getAiring(start)]
        }
        else if start < end {
            return try Airing.makeQuery()
                .filter("air_date", .greaterThanOrEquals, start)
                .filter("air_date", .lessThanOrEquals, end)
                .sort("air_date", .ascending)
                .all()
        }
        else { // start > end
            return try Airing.makeQuery()
                .filter("air_date", .greaterThanOrEquals, end)
                .filter("air_date", .lessThanOrEquals, start)
                .sort("air_date", .descending)
                .all()
        }
    }
    
    func getAiring(_ date: Date) throws -> Airing {
        guard let airing = try Airing.makeQuery()
                                     .filter("air_date", .equals, date)
                                     .first()
            else { throw Abort.notFound }
        return airing
    }
    
    func getLatestEpisodes(_ count: Int) throws -> [Episode] {
        let episodes = try Episode.makeQuery()
                                  .sort("episode_id", .descending)
                                  .limit(count)
                                  .all()
        return episodes
    }
    
    func getEpisodes(start: Int, end: Int) throws -> [Episode] {
        if start == end{
            return try [getEpisode(start)]
        }
        else if start < end {
            return try Episode.makeQuery()
                              .filter("episode_id", .greaterThanOrEquals, start)
                              .filter("episode_id", .lessThanOrEquals, end)
                              .sort("episode_id", .ascending)
                              .all()
        }
        else { // start > end
            return try Episode.makeQuery()
                              .filter("episode_id", .greaterThanOrEquals, end)
                              .filter("episode_id", .lessThanOrEquals, start)
                              .sort("episode_id", .descending)
                              .all()
        }
    }
    
    func getEpisode(_ id: Int) throws -> Episode {
        guard let episode = try Episode.find(id) else { throw Abort.notFound }
        return episode
    }
}
