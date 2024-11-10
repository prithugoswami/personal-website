---
title: using xxd to create binary data
date: 2022-05-03T15:11:00Z
slug: using-xxd-to-create-binary-data
tags:
- cli
- unix
---

`xxd` is a great tool. I have seen it be use in so many places. For some weird
reason though it seems to come packaged with `vim`?. Don't know about other
distros, but that's the case with Arch. Seems like `xxd` was created by Bram
and is a part of vim source code. Haven't looked into it further, but that's
what I concluded.

Anyways here's a small example:

```sh
echo -en "89504e470d0a1a0a0000000d4948445200000001000000010100000000376ef9240000000a4944415478016360000000020001737501180000000049454e44ae426082" | xxd -r -p
```

The `-r` does the reverse of what xxd is meant to normally do, i.e
print hexdump of a binary data. The `-p` just tells it to treat the input as
'plain hexdump' (which is a single line of hex digits without any other
formatting)

