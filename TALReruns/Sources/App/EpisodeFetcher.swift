//
//  EpisodeFetcher
//  TALReruns
//
//  Created by Matt Goldman on 9/17/17.
//
//

import Vapor
import SwiftSoup
import Foundation

public final class EpisodeFetcher {

    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    public init() {}
    
    public func fetch(_ url: String, drop: Droplet) throws {
        let res = try drop.client.get(url)
        let doc = try SwiftSoup.parse(res.description, url)
        let nodes = try doc.getElementsByClass("slider")
        
        for node in nodes {
            
            guard let image = try node.getElementsByClass("image").first()
                else { return }
            let urlStub = try image.attr("href")
            let episodeUrl = url + urlStub
            
            guard let link = try image.getElementsByClass("active").first()
                else { return }
            let imageUrlStub = try link.attr("src")
            let imageUrl = "https:" + imageUrlStub
            
            guard let header = try node.getElementsByTag("h3").first()?.text()
                else { return }
            guard let idx = header.characters.index(of: " ") else { return }
            let number = header.substring(to: header.index(before: idx))
            let title = header.substring(from: header.index(after: idx))
        
            guard let dateString = try node.getElementsByClass("date")
                                           .first()?
                                           .text()
                else { return }
            guard let date = EpisodeFetcher.formatter.date(from: dateString)
                else { return }
            
            // get the description from the episode page to ensure getting the full text
            let episodePage = try drop.client.get(episodeUrl)
            let episodeHtml = try SwiftSoup.parse(episodePage.description, url)

            guard let episodeInfo = try episodeHtml.getElementsByClass("top-inner")
                                                   .first()
                else { return }
            guard let description = try episodeInfo.getElementsByClass("description")
                                                   .first()?
                                                   .text()
                else { return }
            guard let originalAirDateString = try episodeInfo.getElementsByClass("date")
                                                             .first()?
                                                             .text()
                else { return }
            guard let originalDate = EpisodeFetcher.formatter.date(from: originalAirDateString)
                else { return }
            
            let episode = Episode()
            let airing = Airing()
            
            episode.episodeId = Int(number)!
            episode.title = title
            episode.episodeUrl = episodeUrl
            episode.imageUrl = imageUrl
            episode.description = description
            
            airing.episodeId = episode.episodeId
            airing.airDate = date

            // new episode
            if airing.airDate == originalDate {
                try drop.database?.transaction { conn in
                    if try Episode.makeQuery(conn).find(episode.episodeId) == nil {
                        print("NEW EPISODE FOUND")
                        try episode.makeQuery(conn).save()
                    }
                    if try Airing.makeQuery(conn).filter("air_date", .equals, airing.airDate).first() == nil {
                        try airing.makeQuery(conn).save()
                    }
                }
            }
            else {  // IT'S A RERUN! It's the whole purpose of this goddamn site!
                try drop.database?.transaction { conn in
                    if try Airing.makeQuery(conn).filter("air_date", .equals, airing.airDate).first() == nil {
                        print("WE GOT A RERUN, BOYS!!!!")
                        try airing.makeQuery(conn).save()
                    }
                }
            }
        }
    }
}
