---
title: python one-liners using list composoition
date: 2020-05-13T11:34:00Z
slug: python-one-liners-using-list-composoition
tags:
- python
- unix
---

TIL that there are really good ways of writing one-liners in python. I knew
they existed but today I took a closer look at them. Most of the iterations can
be done using list composition. You don't even have to be composing a list,
you could be just executing a normal function call like in the example below
uses "print"

```
curl -s https://www.imdb.com/list/ls020046354/export  |\
    python -c 'import csv,sys;[print (a["Genres"]) for a in csv.DictReader(sys.stdin)]'
```

