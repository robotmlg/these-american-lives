//
//  EpisodeRepository.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/9/17.
//
//

final class EpisodeRepository {
    
    func getLatestAirings(_ count: Int, offset: Int = 0) throws -> [Airing] {
        return try Airing.makeQuery()
                         .sort("air_date", .descending)
                         .limit(count, offset: offset)
                         .all()
    }
    
    func getLatestEpisodes(_ count: Int, offset: Int = 0) throws -> [Episode] {
        return try Episode.makeQuery().sort("episode_id", .descending).limit(count, offset: offset).all()
    }
}
