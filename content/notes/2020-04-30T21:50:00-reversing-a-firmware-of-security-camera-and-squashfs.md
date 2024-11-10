---
title: reversing a firmware of security camera and squashfs
date: 2020-04-30T21:50:00Z
slug: reversing-a-firmware-of-security-camera-and-squashfs
tags:
- security
- reverse engineering
- firmware
---

I saw a [cool video][1] by ghidra ninja on yt that went over firmware reversing
for an a small security camera. He got the firmware from the site of the
manufacturer and went over binwalk and showed how there's a linux
filesystem on it in squashfs form. This was really amusing &mdash; the
fact that there is a whole file system in a single binary. He then goes on
to to see a rc script that runs on the device (this is after separating the
filesystem and unsquashing it) and edits that code to include a reverse
shell using nc. Some version of nc do not have the `-e` flag though and there's a
workaround for that in the man page of nc itself. I find that kind of
ironic.

[1]: https://youtu.be/hV8W4o-Mu2o 

