import App
import Jobs

// configure server
let config = try Config()

try config.setup()

// run server
let drop = try Droplet(config)

try drop.setup()

let fetcher = EpisodeFetcher()

Jobs.oneoff {
    try fetcher.fetch("https://www.thisamericanlife.org", with: drop)
}

try drop.run()
