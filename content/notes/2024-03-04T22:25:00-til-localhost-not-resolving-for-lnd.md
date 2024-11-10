---
title: localhost not resolving for some programs
date: 2024-03-04T22:25:00Z
slug: til-localhost-not-resolving-for-lnd
tags:
- lnd
- troubleshoot
- dns
---

# Check your `/etc/hosts`
So ran into this stupid error where lnd was not starting because it was trying to lookup `localhost` and it couldn't resolve it so it asks the DNS server (1.1.1.1) and obviously can't resolve it either.

```
failed to load config: lookup localhost on 1.1.1.1:53: no such host

```

Add this to  `/etc/hosts`

```
127.0.0.1 localhost
```
