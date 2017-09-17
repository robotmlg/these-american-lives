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
    let res = try drop.client.get("https://www.thisamericanlife.org")
    try fetcher.fetch(String(describing: res.description))
}

try drop.run()
