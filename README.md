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
1. Add a `TALReruns/Config/postgresl.json` with your db information
```
{
    "hostname": "127.0.0.1",
    "user": "<user>",
    "password": "<password>",
    "database": "<database>",
    "port": 5432
}
```
2. `$ vapor run serve`.  The app will scrape all needed episodes from thisamericanlife.org, and any re-runs shown on the homepage

# What's next?
- [ ] User submission of past re-runs via a real form instead of some Google crap
- [ ] Pre-air episodes change their images when they air.  Update the scrape job to pull the new image.
