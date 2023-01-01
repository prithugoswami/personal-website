---
title: "Using server-side git hooks to auto publish blog posts"
date: 2020-10-28T00:20:37+05:30
description: "Setting up a server side git hook to automatically build this hugo site which is then served by nginx"
---

Git hooks are great to automate your software development workflow. They can be
used to implement CI/CD workflows. Many PaaS services like
[Netlify](https://netlify.com) and [Heroku](https://heroku.com) trigger a build
process of your app or website when you push to a remote repository. In this
post I want to go through how one could implement that automated process using
git hooks for a static blog using just a bash script with nginx serving the
files on a VPS.


## Setting up a remote git repository

Setting up a remote git repository on the VPS is as easy as doing:

```
$ git init --bare website
```

Usually it's a practice of creating a new user called 'git' on your server to
have access to your git repositories through ssh. I keep my repositories in the
home directory of the 'git' user on my server. My git clone command would be
something like this:

```
$ git clone git@git.prithu.xyz:website
```

There are other ways you can set up a remote git repository—using the git or
http protocols. I would suggest one reads the chapter [Git on the
Server](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) from
the wonderful book on git - [Pro Git](https://git-scm.com/book/en/v2) to get to
know them.

If I already have a local repository, then I just push to this new one by
adding it as a remote using:

```
$ git remote add origin git@git.prithu.xyz:website
$ git push --set-upstream origin master
```

...Or initialize a new one:

```
$ git init website
$ cd website
$ git remote add origin git@git.prithu.xyz:website
$ cat "A repo for my website" > README.md
$ git commit -am 'Initial commit'
$ git push origin master
```

## Understanding hooks

A hook is basically code that runs as a result of some event. Here the hooks
are basically executable scripts/programs and reside in the `.git/hooks`
directory of a git repo. By default this directory has example scripts for a few
hooks (go take a look at them). You can read the man page
[githooks(5)](https://git-scm.com/docs/githooks) to get a list of all the
available git hooks.

In git, we have client-side hooks and server-side hooks. Client-side git hooks
run on your machine when you perform actions on your local git repo.
`pre-commit` is a client-side hook that runs before you commit something, you
can use this hook to check for what is being committed and run tests. For
example, to check if the formating of the code conforms to a style guide, or
perform some sort of static analysis to find bugs and vulnerabilities.
`post-merge` runs after a successful merge takes place. The `commit-msg` hook
is invoked on `git commit` and gets the name of the file that holds the commit
message.  Checks can be performed on the commit message to see whether or not
it conforms to a standard format. If the hook exits with a non-zero cdoe, the
commit is aborted.

We also have server-side hooks that are invoked on the remote repository.
`pre-recieve` hook runs before refs are updated on the remote, i.e before there
are any changes on the remote repository. The script can exit with a non-zero
code and the push won't be accepted and the client will be notified of the
failure.  `post-recieve` on the other hand runs when all the refs are updated
on the remote. This hook can be thought of as a hook that runs when there is a
'push'.  This hook gets information of what refs were updated - if the master
branch was updated then this information is passed on to the script along with
the last hash and the new updated hash. This information is passed on to the
script through the standard input. For example the `post-recieve` script would
have the following line passed to it through the standard input.

```
689d4729b362e69a27600bb5bc26ca043c67f49f c60d357c48be63ff8ad8a6f94ab2f525332a9cd7 refs/heads/master
```

`689d472` is the old object hash, `c60d357` is the new hash value and
`refs/heads/master` is the ref being updated. So the `master` branch is now
pointing to `c60d357`

A hook script can be written in any language as long as it can be an executable
file.

## Writing a hook script

I will be using a simple shell script to checkout the latest commit on the
`website` repo, build the Hugo site and copy it to a location which will be
served by nginx.

```
#!/bin/bash

set -o pipefail
read ref
echo "[`date`] $ref" >> /home/git/.build/logs/git
branch=$(echo $ref | cut -d ' ' -f 3)

if [ "$branch" = "refs/heads/master" ]
then
  echo "Building Hugo Site"
  cd /home/git/.build/
  [ -d 'website' ] && rm -rf website
  git clone /home/git/website > /dev/null 2>&1 && cd website

  logdate="$(date +%Y-%m-%d-%H%M)"
  hugo | tee "/home/git/.build/logs/$logdate.log" || exit 1

  rm -rf /home/git/.build/public
  mv public /home/git/.build/

  echo "Build complete"
fi
```

This script builds the Hugo site and then places the resultant static files in
the `/home/git/.build/public` directory. It's always a good idea to keep logs
and hence I log every build in the `/home/git/.build/logs/` directory. Now, all
I need is a webserver serving those files in the `public/` directory.

In nginx for example, the following server block will do.

```
server {
    listen 80 ;
    listen [::]:80 ipv6only=on;
    server_name  prithu.xyz;
    root   /var/www/website;
    charset utf-8;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

I then create a symbolic link - `/var/www/website` ->
`/home/git/.build/public` 

```
# ln -s /home/git/.build/public /var/www/website
```

I do this as the 'git' user does not have permissions to write to `/var/www/`;
hence a symbolic link is useful here. There might be other housekeeping chores
to be done like making sure that the 'git' user has permissions to do things
the script will do as the script is run as the 'git' user.

Also, another thing to note is - anything the script writes to stdout will be
displayed to the client. The above script writes to the stdout a copy of Hugo's
output log.

```
$ git commit -m "some changes"
$ git push myrepo master
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 316 bytes | 316.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote:
remote: Building Hugo Site
remote:
remote: Start building sites …
remote: on.
remote: WARN 2021/01/15 11:34:13 found no layout file for "HTML" for kind "taxonomy": You should create a template file which matches Hugo Layouts Lookup Rules for this combinati
remote: on.
remote: WARN 2021/01/15 11:34:13 found no layout file for "HTML" for kind "term": You should create a template file which matches Hugo Layouts Lookup Rules for this combination.
remote: 
remote:                    | EN
remote: -------------------+-----
remote:   Pages            | 21
remote:   Paginator pages  |  0
remote:   Non-page files   |  5
remote:   Static files     | 19
remote:   Processed images |  0
remote:   Aliases          |  0
remote:   Sitemaps         |  1
remote:   Cleaned          |  0
remote: 
remote: Total in 417 ms
remote:
remote: Build complete
remote:
To git.prithu.xyz:website
   4e7bec0..611ac8c  master -> master
```
And that's it! Every time I push to the master branch of this remote, my Hugo
site will be built and "deployed". 
