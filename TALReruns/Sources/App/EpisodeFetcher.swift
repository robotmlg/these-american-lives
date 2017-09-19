//
//  EpisodeFetcher
//  TALReruns
//
//  Created by Matt Goldman on 9/17/17.
//
//

import Vapor
import SwiftSoup


public final class EpisodeFetcher {
    
    public init() {}
    
    public func fetch(_ url: String, with: Droplet) throws {
        let res = try with.client.get(url)
        let doc = try SwiftSoup.parse(res.description, url)
        let nodes = try doc.getElementsByClass("slider")
        
        var episodes: [Airing] = []
        
        for node in nodes {
            
            let airing: Airing = Airing()
            
            guard let header = try node.getElementsByTag("h3").first()?.text() else { return }
            guard let idx = header.characters.index(of: " ") else { return }
            let number = header.substring(to: header.index(before: idx))
            let title = header.substring(from: header.index(after: idx))
            
            guard let image = try node.getElementsByClass("image").first() else { return }
            let urlStub = try image.attr("href")
            let episodeUrl = url + urlStub
            
            guard let link = try image.getElementsByClass("active").first() else { return }
            let imageUrlStub = try link.attr("src")
            let imageUrl = "https:" + imageUrlStub
            
            guard let content = try node.getElementsByClass("content").first() else { return }
            let description = try content.data()
            
            airing.episodeId = Int(number)!
            airing.title = title
            airing.episodeUrl = episodeUrl
            airing.imageUrl = imageUrl
            airing.description = description
            
            episodes.append(airing)
        }
        
        try print(episodes.makeJSON())
    }
}
