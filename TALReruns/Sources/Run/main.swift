import App
import Jobs
import LeafErrorMiddleware

// configure server
let config = try Config()

config.addConfigurable(middleware: LeafErrorMiddleware.init, name: "leaf-error")

try config.setup()

// run server
let drop = try Droplet(config)

try drop.setup()

let fetcher = EpisodeFetcher(drop: drop)

try fetcher.intializeEpisodes()

Jobs.add(interval: .hours(1)) {
    try fetcher.scrapeNewEpisodes()
}

try drop.run()
