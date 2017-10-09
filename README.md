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
1. Setup the db schema according to `schema.sql`.
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
3. `$ vapor run serve`.  The app will scrape all needed episodes from thisamericanlife.org, and any re-runs shown on the homepage

# What's next?
- [ ] Copy images locally so I'm not hot-linking thisamericanlife.org (sorry guys) and nothing breaks if the image is changed
- [ ] User submission of past re-runs
