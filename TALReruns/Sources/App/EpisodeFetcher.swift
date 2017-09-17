//
//  EpisodeFetcher
//  TALReruns
//
//  Created by Matt Goldman on 9/17/17.
//
//

import Kanna

public final class EpisodeFetcher {
    
    public init() {}
    
    public func fetch(_ htmlString: String) throws {
        if let html = HTML(html: htmlString, encoding: .utf8) {
            for node in html.xpath("//div[contains(@class, 'slider')]") {
                print(node.toHTML!)
            }
        }
    }
}
