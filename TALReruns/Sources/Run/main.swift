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

let fetcher = EpisodeFetcher()

Jobs.add(interval: .hours(1)) {
    try fetcher.fetch("https://www.thisamericanlife.org", drop: drop)
}

try drop.run()
