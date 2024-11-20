---
title: useful git tidbits
date: 2024-02-10T13:05:00Z
slug: usuful-git-tidbits
tags:
- git
- snippets
---

1. `--force-with-lease`

`git push --force-with-lease` -- safer than just `--force` since if it doesn't expect the same commit before the force push to be there as yours, it doesn't push it.


2. `git maintenance start`

makes things faster. Does a bunch of stuff in the config that does automatic stuff in the background using systemd timers

3. `git blame -w -C -C -C`

much better than just git blame cause it's smarter about moving of the lines and ignores whitespaces.

4. `git log -S {regex|string}`

filter git log output that has the regex in


5. `git ls-remote`

Can be used to pull in the PRs of a remote repository, we don't have to add PR's repo as remotes



