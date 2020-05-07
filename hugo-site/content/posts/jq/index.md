---
title: "Using jq to display cricket scores on i3bar"
date: 1554643152
description: "jq is a command line utility that parses JSON data and gives you the ability to access it using a simple syntax"
tags:
- i3
- unix utilities
- command line
---

![screenshot](./screen.png)

It's the IPL season and I thought why not keep a track of the score of the
matches that are in progress. I have two tests tomorrow and I don't want to be
wasting time looking at the scores every now and then; instead let's spend some
*more* time looking into an utility that I haven't used before and test and play
around with it. I don't even like cricket that much.

The utility I am talking about here is `jq`. `jq` is a command-line JSON
parser. You can think of it like awk that is tailord to work with JSON.
Following the UNIX philosophy, `jq` can take it's input from the standard input
or from a file.  That means we can pipe it's output to other programs or pipe
in from other programs into it. `jq` has a very straight forward man page.  It
has a mini language of it's own which is quite intuitive.

The command below fetches the information using cricbuzz. Turns out they have
an undocumented API that is publicly usable. We get the score of the batting
side and also the status of the match. ` tr -d \" | tr \n ' '` gets rid of
double quotes and converts the newlines into spaces.


{{< highlight bash >}}
#!/usr/bin/bash
curl -s https://www.cricbuzz.com/match-api/livematches.json\
    | jq '.matches."22455"|.score.batting.score,.status'\
    | tr -d \" | tr '\n' ' '


{{< /highlight >}}

**Output**: 
`"145/5 (18.0 Ovs) Delhi Capitals need 5 runs in 12 balls"`


The script below sends a notification with the current score, run rate, and
balls of the previous overs for the match id `22454`.

{{< highlight bash >}}

#!/usr/bin/bash
notify-send "$(curl -s https://www.cricbuzz.com/match-api/livematches.json\
    | jq '.matches."22454".score |.batting.score, .crr, .prev_overs'\
    | tr \" " ")"

{{< /highlight >}}

I can then place them in `~/.config/i3blocks` and configure
[i3blocks](https://www.github.com/vivien/i3blocks) to run the script every
10-15 seconds.

    [match]
    command=match_score
    interval=10
