# These American Lives
Tracking reruns of [This American Life](thisamericanlife.org)

## What is this?
This is a web app that tracks when each episode of This American Life is re-aired. [thisamericanlife.org](https://thisamericanlife.org) doesn't have this information.

## Why?
Basically I got fed up with an old rerun getting posted, and I start listening but then 5 minutes in I say "wait a minute, I've already heard this episode from 6 years ago, they just reran it last month!"
So I spent hours building this site to save me 5 minutes every few weeks, because that's the kind of guy I am.

## How does it work?
The site regularly scrapes [thisamericanlife.org](https://thisamericanlife.org) for updated episode information and updates its own database of episodes and airings.

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
- [ ] Link together episodes with later "updated" versions e.g. [628](https://www.thisamericanlife.org/radio-archives/episode/628/in-the-shadow-of-the-city-2017) is an updated version of [307](https://www.thisamericanlife.org/radio-archives/episode/307/in-the-shadow-of-the-city)
  - [ ] Maybe grab the info about each segment and display each episode that those appear in?... hm...
- [ ] Statistics page
- [ ] Episode search
- [ ] User submission of past re-runs via a real form instead of some Google crap
- [ ] Better design from someone who actually know what they're doing
