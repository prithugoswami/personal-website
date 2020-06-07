---
title: "The beauty of Unix pipelines"
date: 2020-02-02T17:45:30+05:30
description: "Some examples of using unix tools in a pipeline"
tags:
- unix
- command line
- scripts
---

The Unix philosophy lays emphasis on building software that is simple and
extensible. Each piece of software must do one thing and do it well. And that
software should be able to work with other programs through a common interface
-- a text stream. This is one of the core philosophies of Unix which makes it
so powerful and intuitive to use.

This is an excerpt from [The Unix Programming
Envirnonment](https://en.wikipedia.org/wiki/The_UNIX_Programming_Environment)

> Even though the UNIX system introduces a number of innovative programs and
> techniques, no single program or idea makes it work well. Instead, what makes
> it effective is the approach to programming, a philosophy of using the
> computer. Although that philosophy can't be written down in a single sentence,
> at its heart is the idea that the power of a system comes more from the
> relationships among programs than from the programs themselves. Many UNIX
> programs do quite trivial things in isolation, but, combined with other
> programs, become general and useful tools.

I think that explains it pretty well. Also, [watch Brian
Kernighan](https://youtu.be/tc4ROCJYbm0?t=297) being a complete chad and
explaining fundamentals of the UNIX OS where he also goes through an example of
using pipes. 

In this post though, I would like to show some examples of this
philosophy in action -- of how one can use different unix tools together to
accomplish something powerful.

Examples:
- Printing a leaderboard of authors based on number of commits to a git repo
- Browse memes from [/r/memes](https://reddit.com/r/memes) and set your wallpaper from [/r/earthporn](https://reddit.com/r/earthporn) 
- Get a random movie from an IMDb list

## Example 1 - Printing a leaderboard of authors based on number of commits in a git repo

Let's start with a simple one -- display a list of authors/contributors of a git
repo sorted based on the number of commits and sort the list in descending
order (most commits contributed at the top). This is a simple task when you
think of it in terms of piplines. `git log` is used to display commit logs. We
can pass the `--format=<format>` option to it and mention what format we want
the commits to be displayed in. `--format='%an'` just prints the author's name
for each commit.

{{< highlight bash >}}
$ git log --format='%an'

Alice
Bob
Denise
Denise
Candice
Denise
Alice
Alice
Alice
{{< /highlight >}}

Now we can use the `sort` utility to sort them alphabetically.

{{< highlight bash >}}
$ git log --format='%an' | sort

Alice
Alice
Alice
Alice
Bob
Candice
Denise
Denise
Denise
{{< /highlight >}}

Next we use `uniq`

{{< highlight bash >}}
$ git log --format='%an' | sort | uniq -c

    4 Alice
    1 Bob
    1 Candice
    3 Denise
{{< /highlight >}}

According to `uniq`'s man page:

> **uniq** - report or omit repeated lines 
>
> Filter adjacent matching lines from INPUT (or standard input), writing to
> OUTPUT (or standard output).

So `uniq` prints out repeated lines, but only those that appear _adjacent to
eachother_. That is why we had to pass the output first to `sort`. The `-c` flag
prefixes each line by the number of occurrences.

You can see the output is still sorted alphabetically. So now all that is
remaining is sort it numerically. There's a flag for that in `sort`, the
`-n` flag. It considers the numbers based on their numerical value.

{{< highlight bash >}}
$ git log --format='%an' | sort | uniq -c | sort -nr

    4 Alice
    3 Denise
    1 Candice
    1 Bob
{{< /highlight >}}

The `-r` flag was also included to print the list in reverse order. By default
it sorts it in the ascending order. And their you have it -- A list of authors
sorted according to number of commits.


## Example 2 - Browse memes from [/r/memes](https://reddit.com/r/memes) and set your wallpaper from [/r/earthporn](https://reddit.com/r/earthporn)

Did you know that you can just append "`.json`" to a reddit url to get a json
response instead of the usual html? This allows for a world of possibilities!
One such is browsing memes right from the command line (well not entirely,
because the actual image will be displayed on a GUI program). We can simply curl
or wget the url -- https://reddit.com/r/memes.json


{{< highlight bash >}}
$ wget -O - -q 'https://reddit.com/r/memes.json'

'{"kind": "Listing", "data": {"modhash": "xyloiccqgm649f320569f4efb427cdcbd89e68aeceeda8fe1a", "dist": 27, "children":
[{"kind": "t3", "data": {"approved_at_utc": null, "subreddit": "memes",
"selftext": "More info available at....'
...
...
More lines
...
...

{{< /highlight >}}

I use wget here because it seems like the Curl User-Agent gets treated
differently. Obviously, you can get around this by simply changing the
'User-Agent' header, but I just went with `wget`. Wget has a `-O` to provide
the output filename. Most programs that take such an option also allow a value
of `-` which represents the standard output or input depending on the context.
The `-q` option just tells wget to be quiet and not print things like progress
status. Now we get a big JSON structure to work with. Now, to parse and use this
JSON data meaningfully on the command line, we can use
[`jq`](https://stedolan.github.io/jq/). `jq` can be thought of as `sed`/`awk`
for JSON. It has a simple intuitive language of it's own you can refer from
it's man page.

If you take a look at the response JSON, it looks something like this:

{{< highlight json >}}
{
    "kind": "Listing",
    "data": {
        "modhash": "awe40m26lde06517c260e2071117e208f8c9b5b29e1da12bf7",
        "dist": 27,
        "children": [],
        "after": "t3_gi892x",
        "before": null
    }
}
{{< /highlight >}}

So here we have some response of the type "Listing" and we can see we have an
array of "children". Each element of that array is a post.

This is what one of the elements of the 'children' array looks like:

{{< highlight json >}}
{
    "kind": "t3",
    "data": {
        "subreddit": "memes",
        "selftext": "",
        "created": 1589309289,
        "author_fullname": "t2_4amm4a5w",
        "gilded": 0,
        "title": "Its hard to argue with his assessment",
        "subreddit_name_prefixed": "r/memes",
        "downs": 0,
        "hide_score": false,
        "name": "t3_gi8wkj",
        "quarantine": false,
        "permalink": "/r/memes/comments/gi8wkj/its_hard_to_argue_with_his_assessment/",
        "url": "https://i.redd.it/6vi05eobdby41.jpg",
        "upvote_ratio": 0.93,
        "subreddit_type": "public",
        "ups": 11367,
        "total_awards_received": 0,
        "score": 11367,
        "author_premium": false,
        "thumbnail": "https://b.thumbs.redditmedia.com/QZt8_SBJDdKLVnXK8P4Wr_02ALEhGoGFEeNhpsyIfvw.jpg",
        "gildings": {},
        "post_hint": "image",

        ".................."
        "more lines skipped"
        ".................."
    }
}
{{< /highlight >}}

I have reduced the number of key value pairs in `data`. In total there were 105
items. As you can see there are many interesting data attributes you can fetch
about a post. The one of our interest is `url` of the post. This isn't the url
of the actual reddit post but rather it's the url of the content of the post.
If the post url is what you want then that's `permalink`. So in this case, the
`url` field is the url to the meme's image.

We can simply get the list of of all the urls of of every post using:

{{< highlight bash >}}
$ wget -O - -q reddit.com/r/memes.json | jq '.data.children[] |.data.url'

"https://www.reddit.com/r/memes/comments/g9w9bv/join_the_unofficial_redditmc_minecraft_server_at/"
"https://www.reddit.com/r/memes/comments/ggsomm/10_million_subscriber_event/"
"https://i.imgur.com/KpwIuSO.png"
"https://i.redd.it/ey1f7ksrtay41.jpg"
"https://i.redd.it/is3cckgbeby41.png"
"https://i.redd.it/4pfwbtqsaby41.jpg"
...
...
{{< /highlight >}}

Ignore the first two links, those are basically sticky posts that the mods put,
whose 'url' is same as the 'permalink'.

`jq` reads from the standard input and it's fed the JSON we saw earlier.
`.data.children` is referring to the array of posts I mentioned earlier. And
-- `.data.children[] | .data.url` means, "iterate through every element in the
array and print the 'url' field which is in the 'data' field of every element".

So we get a list of all the urls of the "hot" posts of
[/r/memes](https://reddit.com/r/memes). If you wanted to get the "top" posts of
the this week then you can hit https://reddit.com/r/memes/top.json?t=week. For
top posts of all time? `t=all`, year? `t=year` and so on.

Once we have a list of all the URLs, we can now just pipe it into `xargs`.
Xargs is a really useful utility to build command lines from standard input.
This is what xarg's man page says:

> xargs reads items from the standard input, delimited by blanks (which can be
> protected  with double or single quotes or a backslash) or newlines, and
> executes the command (default is /bin/echo) one or more times with any
> initial-arguments followed by items read from standard input. Blank lines on
> the standard input are ignored

So running something like:

{{< highlight bash >}}
$ echo "https://i.redd.it/4pfwbtqsaby41.jpg" | xargs wget -O meme.jpg -q
{{< /highlight >}}

would be equavalent to running:

{{< highlight bash >}}
$ wget -O meme.jpg -q "https://i.redd.it/4pfwbtqsaby41.jpg"

{{< /highlight >}}

Now, we can just pass the list of URLs to an image viewer, like
[`feh`](https://feh.finalrewind.org/) or
[`eog`](https://wiki.gnome.org/Apps/EyeOfGnome)
that accept a URL as a valid argument.


{{< highlight bash >}}
$ wget -O - -q reddit.com/r/memes.json | jq '.data.children[] |.data.url' | xargs feh

{{< /highlight >}}

Now, feh pops up with the memes and I can just browse through them using the
arrow keys like they were on my local disk.

{{< figure src="feh-meme.png" title="Feh screen" width="100%" >}}

Or I could simply just download all of the images using wget, by replacing
`feh` with `wget` above.

And the possibilities are endless. Another good use of this reddit JSON data is
**setting the wallpaper** of your desktop to the top upvoted image of
[/r/earthporn](https://reddit.com/r/earthporn) from the "hot" section.


{{< highlight bash >}}
$ wget -O - -q reddit.com/r/earthporn.json | jq '.data.children[] |.data.url' | head -1 | xargs feh --bg-fill

{{< /highlight >}}

You can then, if you want, set this up as a cron-job that runs every hour or
so. I use the `head` command here to just print the first line, which would be
the top upvoted post. By it's own, `head` seems to do something very trivial
and unuseful, but in this case, working with other programs, it becomes an
important part.

You see the power of Unix pipelines? That one single line does everything from
fetching JSON data, parsing and getting the relevant data out of it and then
again fetching the image from the URL and finally setting it as the wallpaper.

Another silly thing I used this for was for just downloading memes off of
/r/memes every two hours. This is set up as a cron job on my machine. Now I
have around 19566 memes taking up 4.5G on my disk. Why did I do that? Don't ask
me...


## Example 3 - Get a random movie from an IMDb list

Let's end it with a simple one. IMDb has a feature where they allow you to make
lists. You can also find lists made by other users. For example - [Blow Your
Mind Movies](https://www.imdb.com/list/ls020046354). If you append `/export` to
the url you get the list in a `.csv` format.

{{< highlight bash >}}
$ curl https://www.imdb.com/list/ls020046354/export

Position,Const,Created,Modified,Description,Title,URL,Title Type,IMDb Rating,Runtime (mins),Year,Genres,Num Votes,Release Date,Directors
1,tt0137523,2017-07-30,2017-07-30,,Fight Club,https://www.imdb.com/title/tt0137523/,movie,8.8,139,1999,Drama,1780706,1999-09-10,David Fincher
2,tt0945513,2017-07-30,2017-07-30,,Source Code,https://www.imdb.com/title/tt0945513/,movie,7.5,93,2011,"Action, Drama, Mystery, Sci-Fi, Thriller",471234,2011-03-11,Duncan Jones
3,tt0482571,2017-07-30,2017-07-30,,The Prestige,https://www.imdb.com/title/tt0482571/,movie,8.5,130,2006,"Drama, Mystery, Sci-Fi, Thriller",1133548,2006-10-17,Christopher Nolan
4,tt0209144,2018-01-16,2018-01-16,,Memento,https://www.imdb.com/title/tt0209144/,movie,8.4,113,2000,"Mystery, Thriller",1081848,2000-09-05,Christopher Nolan
5,tt0144084,2018-01-16,2018-01-16,,American Psycho,https://www.imdb.com/title/tt0144084/,movie,7.6,101,2000,"Comedy, Crime, Drama",462984,2000-01-21,Mary Harron
6,tt0364569,2018-01-16,2018-01-16,,Oldeuboi,https://www.imdb.com/title/tt0364569/,movie,8.4,120,2003,"Action, Drama, Mystery, Thriller",491476,2003-11-21,Chan-wook Park
7,tt1130884,2018-10-08,2018-10-08,,Shutter Island,https://www.imdb.com/title/tt1130884/,movie,8.1,138,2010,"Mystery, Thriller",1075524,2010-02-13,Martin Scorsese
8,tt8772262,2019-12-27,2019-12-27,,Midsommar,https://www.imdb.com/title/tt8772262/,movie,7.1,148,2019,"Drama, Horror, Mystery, Thriller",150798,2019-06-24,Ari Aster
{{< /highlight >}}

We can use `cut` to decide which fields we need to print:

{{< highlight bash >}}
$ curl https://www.imdb.com/list/ls020046354/export | cut -d ',' -f 6

Title
Fight Club
Source Code
The Prestige
Memento
American Psycho
Oldeuboi
Shutter Island
Midsommar
{{< /highlight >}}

The `-d` option is to specify the delimiter for each field. What are the fields
separated with? In this case it's a comma (`,`). The `-f` option is the field
number you want to print. In this case the sixth field is the Title of the
movie. This also prints the csv header "Title" so to remove it we can just use
`sed '1 d'`, which just means, **d**elete **1** line from the input stream.

We can then pipe the list of movies into `shuf`. Shuf just shuffles it's input
lines randomly and spits it out.

{{< highlight bash >}}
$ curl https://www.imdb.com/list/ls020046354/export | cut -d ',' -f 6 | sed '1 d' | shuf

American Psycho
Midsommar
Source Code
Oldeuboi
Fight Club
Memento
Shutter Island
The Prestige
{{< /highlight >}}

Now just pipe it into `head -1` or `sed '1 q'` which would print only the first
line. Every time you run this, you should get a random selection.

{{< highlight bash >}}
$ curl https://www.imdb.com/list/ls020046354/export | cut -d ',' -f 6 | sed '1 d' | shuf | head -1

Source Code
{{< /highlight >}}

Now let's say you would also like the URL to be printed along with title, no
problem, `cut` allows you to specify multiple fields to print using `--field=LIST`

{{< highlight bash >}}
$ curl https://www.imdb.com/list/ls020046354/export | cut -d ',' --field=6,7 | sed '1 d' | shuf | head -1

Shutter Island,https://www.imdb.com/title/tt1130884/
{{< /highlight >}}

There is a problem with this though, if the Movie title has a comma in it, then
you would get a totally different field value. One way to overcome this is by
using a python one-liner like this:

{{< highlight bash >}}
python -c 'import csv,sys;[print (a["Title"]) for a in csv.DictReader(sys.stdin)]'
{{< /highlight >}}

{{< highlight bash >}}
$ curl -s https://www.imdb.com/list/ls020046354/export |\
    python -c 'import csv,sys;[print (a["Title"],a["URL"]) for a in csv.DictReader(sys.stdin)]'|\
    shuf | head -1

Oldeuboi https://www.imdb.com/title/tt0364569/ 
{{< /highlight >}}

These were just a few examples, there are so many things you can accomplish in
a single line of shell using pipes.

[View discussion on Hacker News](https://news.ycombinator.com/item?id=23420786)
