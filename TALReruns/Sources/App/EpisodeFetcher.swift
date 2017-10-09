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

    static let baseUrl = "https://www.thisamericanlife.org"
    static let episodeBaseUrl = baseUrl + "/radio-archives/episode/"

    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateStyle = .medium
        return df
    }()

    let drop: Droplet

    public enum Error: Swift.Error {
        case invalidEpisodePageError
        case invalidSplashPageError
    }
    
    public init(drop: Droplet) {
        self.drop = drop
    }

    public func intializeEpisodes() throws {
        let existingEpisodeIds = try Set(OriginalAiring.all().map{$0.episodeId})
        var maxEpisodeId = existingEpisodeIds.sorted().reversed().first
        var allEpisodeIds: Set<Int>
        if (maxEpisodeId == nil) {
            maxEpisodeId = 1
            allEpisodeIds = Set()
        }
        else {
            allEpisodeIds = Set((1...maxEpisodeId!).map{$0})
        }
        let missingIds = allEpisodeIds.subtracting(existingEpisodeIds)

        var episodes: [(Episode, Airing)] = []
        // get missing episodes
        for id in missingIds {
            let episodeUrl = EpisodeFetcher.episodeBaseUrl + String(id)
            let episode = try scrapeEpisodePage(episodeUrl)
            episodes.append(episode)
        }
        // get any future episodes
        var nextEpisodeId = maxEpisodeId!
        while true {
            let episodeUrl = EpisodeFetcher.episodeBaseUrl + String(nextEpisodeId)
            do {
                let episode = try scrapeEpisodePage(episodeUrl)
                try processEpisode(episode.0, originalAiring: episode.1)
                nextEpisodeId += 1
            }
            catch {
                break
            }
        }
    }

    public func scrapeNewEpisodes() throws {
        let res = try drop.client.get(EpisodeFetcher.baseUrl)
        let doc = try SwiftSoup.parse(res.description, EpisodeFetcher.baseUrl)
        let nodes = try doc.getElementsByClass("slider")
        
        for node in nodes {
            let (episodeUrl, airing) = try parseAiringFromHomepageSlide(node)

            // get the description from the episode page to ensure getting the full text
            let (episode, originalAiring) = try scrapeEpisodePage(episodeUrl)

            try processEpisode(episode, originalAiring: originalAiring, airing: airing)
        }
    }

    private func processEpisode(_ episode: Episode,
                                originalAiring: Airing,
                                airing: Airing? = nil) throws {
        // new episode
        if airing == nil || airing!.airDate == originalAiring.airDate {
            try drop.database?.transaction { conn in
                if try Episode.makeQuery(conn)
                              .find(episode.id) == nil {
                    print("NEW EPISODE FOUND")
                    try episode.makeQuery(conn).save()
                }
                if try Airing.makeQuery(conn)
                             .filter("air_date", .equals, originalAiring.airDate)
                             .first() == nil {
                    try originalAiring.makeQuery(conn).save()
                }
            }
        }
        else {  // IT'S A RERUN! It's the whole purpose of this goddamn site!
            try drop.database?.transaction { conn in
                if try Airing.makeQuery(conn)
                             .filter("air_date", .equals, airing!.airDate)
                             .first() == nil {
                    print("WE GOT A RERUN, BOYS!!!!")
                    try airing!.makeQuery(conn).save()
                }
            }
        }
    }

    private func scrapeEpisodePage(_ url: String) throws -> (Episode, Airing) {
        print("Scraping episode page \(url)")
        var episodePage = try drop.client.get(url)
        if (episodePage.status == .movedPermanently) {
            let newUrl = episodePage.headers["Location"]!
            episodePage = try drop.client.get(newUrl)
        }
        else if (episodePage.status != .ok) {
            throw Error.invalidEpisodePageError
        }
        let episodeHtml = try SwiftSoup.parse(episodePage.description, url)

        guard let episodeInfo = try episodeHtml.getElementsByClass("top-inner")
                                               .first()
            else { throw Error.invalidEpisodePageError }

        let image = try episodeInfo.getElementsByTag("img").first()
        var imageUrl: String
        if image != nil {
            let imageUrlStub = try image!.attr("src")
            imageUrl = "https:" + imageUrlStub
        }
        else {
            imageUrl = ""
        }

        guard let header = try episodeInfo.getElementsByTag("h1")
                                          .first()?
                                          .text()
            else { throw Error.invalidEpisodePageError }
        guard let idx = header.characters.index(of: " ")
            else { throw Error.invalidEpisodePageError }
        let number = header.substring(to: header.index(before: idx))
        let title = header.substring(from: header.index(after: idx))

        guard let dateString = try episodeInfo.getElementsByClass("date")
                                                         .first()?
                                                         .text()
            else { throw Error.invalidEpisodePageError }
        guard let airDate = EpisodeFetcher.formatter.date(from: dateString)
            else { throw Error.invalidEpisodePageError }

        guard let description = try episodeInfo.getElementsByClass("description")
                                               .first()?
                                               .text()
            else { throw Error.invalidEpisodePageError }

        let episode = Episode()
        let airing = Airing()
        let episodeId = Int(number)!

        episode.id = Identifier(episodeId)
        episode.title = title
        episode.episodeUrl = url
        episode.imageUrl = imageUrl
        episode.description = description


        airing.episodeId = episodeId
        airing.airDate = airDate

        return (episode, airing)
    }

    private func parseAiringFromHomepageSlide(_ node: Element) throws -> (String, Airing) {
        guard let header = try node.getElementsByTag("h3").first()
            else { throw Error.invalidSplashPageError }
        guard let link = try header.getElementsByTag("a").first()
            else { throw Error.invalidSplashPageError }
        let urlStub = try link.attr("href")
        let episodeUrl = EpisodeFetcher.baseUrl + urlStub

        let headerString = try link.text()
        guard let idx = headerString.characters.index(of: " ")
            else { throw Error.invalidSplashPageError }
        let number = headerString.substring(to: headerString.index(before: idx))
        let episodeId = Int(number)!

        guard let dateString = try node.getElementsByClass("date")
                                       .first()?
                                       .text()
            else { throw Error.invalidSplashPageError }
        guard let date = EpisodeFetcher.formatter.date(from: dateString)
            else { throw Error.invalidSplashPageError }

        let airing = Airing(episodeId: episodeId, airDate: date)

        return (episodeUrl, airing)
    }
}
