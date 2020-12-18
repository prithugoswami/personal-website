---
title: "Using server-side git hooks to auto publish blog posts"
date: 2020-07-28T00:20:37+05:30
draft: true
---

Git hooks are great to automate your software development workflow. They can
also be used to implement CI/CD workflows. Many PaaS like netlify and heroku
trigger a build process of your app or website when you push to a remote
repository. In this post I want to go through how you could implement a similar
process on a VPS for a static blog using just a bash script with nginx serving
the files.


## Setting up a remote git repository

Setting up a remote git repository on the VPS is as easy as doing:

```
git init --bare website.git
```

Usually it's a practice of creating a new user called 'git' on your server to
have access to your git repositories through ssh. I store my repositories in
the home directory of the git user on my server. Then make sure that you have
permissions to ssh as the 'git' user by including your ssh public in the
~/.ssh/authororized_keys file. So my git clone command would look something
like this:

```
git clone git@git.prithu.xyz:website
```

There are other ways you can set up a remote git repository - using the ssh or
http protocols. I would suggest one reads the chapter [Git on the
Server](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) from
the wonderful book on git - [Pro Git](https://git-scm.com/book/en/v2) to get to
know them.

If I already have a local repository, then I just push to this new one by
adding it as a remote using:

```
git remote add myserver git@git.prithu.xyz:website
```

I can also initialize a new repo and add a remote to it manually.

```
$ git init website
$ cd website
$ git remote add origin git@git.prithu.xyz:website
$ cat "A repo for my website" > README.md
$ git commit -am 'Initial commit'
$ git push origin master
```



