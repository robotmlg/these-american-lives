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
    
    public func fetch(_ url: String, with: Droplet) throws {
        let res = try with.client.get(url)
        let doc = try SwiftSoup.parse(res.description, url)
        let nodes = try doc.getElementsByClass("slider")
        
        for node in nodes {
            
            guard let image = try node.getElementsByClass("image").first() else { return }
            let urlStub = try image.attr("href")
            let episodeUrl = url + urlStub
            
            guard let link = try image.getElementsByClass("active").first() else { return }
            let imageUrlStub = try link.attr("src")
            let imageUrl = "https:" + imageUrlStub
            
            guard let header = try node.getElementsByTag("h3").first()?.text() else { return }
            guard let idx = header.characters.index(of: " ") else { return }
            let number = header.substring(to: header.index(before: idx))
            let title = header.substring(from: header.index(after: idx))
        
            guard let dateString = try node.getElementsByClass("date").first()?.text() else { return }
            guard let date = EpisodeFetcher.formatter.date(from: dateString) else { return }
            
            // get the description from the episode page to ensure getting the full text
            let episodePage = try with.client.get(episodeUrl)
            let episodeHtml = try SwiftSoup.parse(episodePage.description, url)

            guard let description = try episodeHtml.getElementsByClass("description").first()?.text() else { return }
            guard let originalAirDateString = try doc.getElementsByClass("date").first()?.text() else { return }
            guard let originalDate = EpisodeFetcher.formatter.date(from: originalAirDateString) else { return }
            
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
                if try Episode.find(episode.episodeId) == nil {
                    try episode.save()
                }
                try airing.save()
            }
            else {  // IT'S A RERUN! It's the whole purpose of this goddamn site!
                print("WE GOT ONE!!!!")
                print(episode)
                print(airing)
                try airing.save()
            }
        }
    }
}
