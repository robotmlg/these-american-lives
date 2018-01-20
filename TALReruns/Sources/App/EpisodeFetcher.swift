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
    static let oneDay: Double = 24 * 60 * 60
    static let twoDays: Double = 2 * oneDay
    static let sevenDays: Double = 7 * oneDay

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

        // get missing episodes
        for id in missingIds {
            let episodeUrl = EpisodeFetcher.episodeBaseUrl + String(id)
            let episode = try scrapeEpisodePage(episodeUrl)
            try processEpisode(episode.0, originalAiring: episode.1)
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
                print("\(error)")
                break
            }
        }
    }

    public func scrapeNewEpisodes() throws {
        let page = try drop.client.get(EpisodeFetcher.baseUrl)
        let html = try SwiftSoup.parse(page.description, EpisodeFetcher.baseUrl)

        let (episodeUrl, airing) = try parseAiringFromHomepage(html)

        // get the description from the episode page to ensure getting the full text
        let (episode, originalAiring) = try scrapeEpisodePage(episodeUrl)

        try processEpisode(episode, originalAiring: originalAiring, airing: airing)

        let (nextEpisodeUrl, nextAiring) = try parseNextWeeksAiring(html)

        let (nextEpisode, nextOriginalAiring) = try scrapeEpisodePage(nextEpisodeUrl)

        try processEpisode(nextEpisode, originalAiring: nextOriginalAiring, airing: nextAiring)
    }

    private func processEpisode(_ episode: Episode,
                                originalAiring: Airing,
                                airing: Airing? = nil) throws {
        // new episode
        if airing == nil || airing!.airDate == originalAiring.airDate {
            try drop.database?.transaction { conn in
                if let existingEpisode = try Episode.makeQuery(conn)
                                                    .find(episode.id) {
                    print("Episode already exists")
                    if existingEpisode.imageUrl != episode.imageUrl ||
                       existingEpisode.title != episode.title ||
                       existingEpisode.description != episode.description {
                        print("Updating image info")
                        existingEpisode.imageUrl = episode.imageUrl
                        existingEpisode.title = episode.title
                        existingEpisode.description = episode.description
                        try existingEpisode.makeQuery(conn).save()
                    }
                }
                else {
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

                let existingAiring = try Airing.makeQuery(conn)
                    .filter("episode_id", .equals, airing?.episodeId)
                    .filter("air_date", .greaterThanOrEquals, airing!.airDate - EpisodeFetcher.twoDays)
                    .filter("air_date", .lessThanOrEquals, airing!.airDate + EpisodeFetcher.twoDays)
                    .first()

                if existingAiring == nil {
                    print("WE GOT A RERUN, BOYS!!!!")
                    try airing!.makeQuery(conn).save()
                }
                else {
                    print("Updating date on existing airing because Ira Glass can't code properly")
                    existingAiring?.airDate = max(airing!.airDate, existingAiring!.airDate)
                    try existingAiring!.makeQuery(conn).save()
                }
            }
        }
    }

    private func downloadAndSaveImage(_ url: String) throws -> String {
        let fileManager = FileManager.default
        let imagesPath = drop.config.publicDir + "images"
        guard let fileNameBytes = url.split(separator: "/").last
            else { return "" }
        var fileName = String(fileNameBytes)

        if let endIdx = fileName.index(of: "?") {
            fileName = String(describing: fileName[..<endIdx])
        }

        let filePath = imagesPath + "/" + fileName
        guard let imageData = try drop.client.get(url).body.bytes
            else { return "" }

        if !fileManager.fileExists(atPath: imagesPath) {
            try fileManager.createDirectory(atPath: imagesPath, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: Data(bytes: imageData))
        }

        return "/images/" + fileName
    }

    private func scrapeEpisodePage(_ url: String) throws -> (Episode, Airing) {
        print("Scraping episode page \(url)")
        var episodeUrl = url
        var episodePage = try drop.client.get(episodeUrl)
        if (episodePage.status == .movedPermanently) {
            episodeUrl = episodePage.headers["Location"]!
            episodePage = try drop.client.get(episodeUrl)
        }
        else if (episodePage.status != .ok) {
            throw Error.invalidEpisodePageError
        }
        let episodeHtml = try SwiftSoup.parse(episodePage.description, url)
        guard let episodeHeader = try episodeHtml.getElementsByClass("episode-header").first()
            else { throw Error.invalidEpisodePageError }

        guard let titleBlock = try episodeHeader.getElementsByClass("episode-title").first()
            else {throw Error.invalidEpisodePageError }
        guard let title = try titleBlock.getElementsByTag("h1").first()?.text()
            else {throw Error.invalidEpisodePageError }

        guard let number = try episodeHeader.getElementsByClass("field-name-field-episode-number").first()?.text()
            else {throw Error.invalidEpisodePageError }

        guard let dateString = try episodeHeader.getElementsByClass("field-name-field-radio-air-date").first()?.text()
            else {throw Error.invalidEpisodePageError }
        guard let airDate = EpisodeFetcher.formatter.date(from: dateString)
            else { throw Error.invalidEpisodePageError }

        guard let description = try episodeHeader.getElementsByClass("field-type-text-with-summary").first()?.text()
            else { throw Error.invalidEpisodePageError }

        let image = try episodeHtml.getElementsByClass("episode-image").first()?.getElementsByTag("img").first()
        var imageUrl: String
        if image != nil {
            imageUrl = try image!.attr("src")
            if !imageUrl.contains(".org") {
                imageUrl = EpisodeFetcher.baseUrl + imageUrl
            }
        }
        else {
            imageUrl = ""
        }

        let localImage = try downloadAndSaveImage(imageUrl)

        let episode = Episode()
        let airing = Airing()
        let episodeId = Int(number)!

        episode.id = Identifier(episodeId)
        episode.title = title
        episode.episodeUrl = episodeUrl
        episode.imageUrl = localImage
        episode.description = description


        airing.episodeId = episodeId
        airing.airDate = airDate

        return (episode, airing)
    }

    private func parseAiringFromHomepage(_ html: Document) throws -> (String, Airing) {
        print("Scraping homepage")

        guard let episodeHeader = try html.getElementsByClass("view-homepage").first()
            else { throw Error.invalidSplashPageError }

        guard let header = try episodeHeader.getElementsByTag("h2").first()
            else { throw Error.invalidSplashPageError }
        guard let link = try header.getElementsByTag("a").first()
            else { throw Error.invalidSplashPageError }
        let urlStub = try link.attr("href")
        let episodeUrl = EpisodeFetcher.baseUrl + urlStub

        guard let numberString = try episodeHeader.getElementsByClass("field-name-field-episode-number").first()?.text()
            else {throw Error.invalidEpisodePageError }
        // "This Week: ###"
        let number = String(describing: numberString.split(separator: " ").last!)
        let episodeId = Int(number)!

        guard let dateString = try episodeHeader.getElementsByClass("field-name-field-radio-air-date").first()?.text()
            else {throw Error.invalidEpisodePageError }
        guard let date = EpisodeFetcher.formatter.date(from: dateString)
            else { throw Error.invalidEpisodePageError }

        let airing = Airing(episodeId: episodeId, airDate: date)

        return (episodeUrl, airing)
    }

    private func parseNextWeeksAiring(_ html: Document) throws -> (String, Airing)
    {
        print("Scraping next week's airing")

        guard let nextWeekButton = try html.getElementsByClass("next-week").first()
            else {
                print("No next-week button found")
                throw Error.invalidSplashPageError
            }
        guard let link = try nextWeekButton.getElementsByTag("a").first()
            else { throw Error.invalidSplashPageError }
        let urlStub = try link.attr("href")
        let episodeUrl = EpisodeFetcher.baseUrl + urlStub

        // "/###/title-text"
        let number = String(describing: urlStub.split(separator: "/").first!)
        let episodeId = Int(number)!

        let lastAiring = try Airing.makeQuery()
                                   .sort("air_date", .descending)
                                   .limit(1)
                                   .first()

        let date = lastAiring!.airDate.addingTimeInterval(EpisodeFetcher.sevenDays)

        let airing = Airing(episodeId: episodeId, airDate: date)

        return (episodeUrl, airing)
    }
}
