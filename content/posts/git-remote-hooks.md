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
git init --bare website
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
git remote add myrepo git@git.prithu.xyz:website
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

## Understanding hooks

A hook is basically code that runs as a result of some event. In git we have
client-side hooks and server-side hooks. Client-side git hooks run on your
machine when perform actions on your local git repo. `pre-commit` is a
client-side hook that runs before you commit something, you can use this hook
to check for what is being commited and run tests for example to check if the
formating of the code conforms to a style guide. `post-merge` runs after a
successful merge takes place. `commit-msg` - This hook is invoked on `git
commit` and gets the name of the file that holds the commit message. Checks can
be performed on the commit message to see whether or not it conforms to a
standard format. If the hook exits with a non-zero cdoe, the commit is aborted.

We also have server-side hooks that live on the remote's bare repository.
`pre-recieve` hook runs before refs are updated on the remote. The script can
exit with a non-zero code and the push won't be accepted and the client will be
notified. `post-recieve` on the other hand runs when all the refs are updated
on the remote. This hook can be thought of as a hook that runs when there is a
'push'. This hook gets information of what refs were updated - if the master
branch was updated then this information is passed on to the script along with
the last hash and the new updated hash.


