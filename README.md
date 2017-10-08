# These American Lives
Tracking reruns of [This American Life](thisamericanlife.org)

## What is this?
This is a web app that tracks when each episode of This American Life is re-aired

## Why?
Because thisamericanlife.org doesn't have this information.  Thus, unfortunately, this will only track future re-runs and not past re-runs

## Build
- install Postgres
- install [Vapor](http://vapor.codes)
```
$ cd TALReruns
$ vapor build
```

## Run
0. (Optional) Run `python3 scraper.py` to scrape the latest episode data.  You'll need to split up the single output file from this into two files, one of episode data, one of airing data, as the included csvs show.
1. Setup the db schema according to `schema.sql`.  Update the paths in here to point to your data files, if you want to import episode data
2. Add a `TALReruns/Config/postgresl.json` with your db information
```
{
    "hostname": "127.0.0.1",
    "user": "<user>",
    "password": "<password>",
    "database": "<database>",
    "port": 5432
}
```
3. `$ vapor run serve`

# What's next?
- [ ] Copy images locally so I'm not hot-linking thisamericanlife.org (sorry guys) and nothing breaks if the image is changed
- [ ] User submission of past re-runs
- [ ] Replace Python script with Swift to load existing episodes from thisamericanlife.org on boot, if not found in the database already
