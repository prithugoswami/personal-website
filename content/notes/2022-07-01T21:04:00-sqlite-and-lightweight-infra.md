---
title: sqlite and lightweight infra
date: 2022-07-01T21:04:00Z
slug: sqlite-and-lightweight-infra
tags:
- infra
- database
---

I kinda want to use this space to experiment and see what very lightweight tech
stack would feel like. Something on the lines of a single vm instace running
flask or go-gin (or some other production grade go framework) with sqlite with
nginx (or cady maybe) as a front.

There's also pocketbase which can be used for this. But more simply packaing litestream along with sqlite3 in a docker container should do the trick. litestream will then just replicate it to s3.

Links 
- [Anirudh's post on using fly.io for his fedi instance](https://icyphox.sh/blog/honk-fly/)
- [I'm All-In on Server-Side SQLite](https://fly.io/blog/all-in-on-sqlite-litestream/)

