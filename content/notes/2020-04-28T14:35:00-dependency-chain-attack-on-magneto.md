---
title: dependency chain attack on magneto
date: 2020-04-28T14:35:00Z
slug: dependency-chain-attack-on-magneto
tags:
- security
- infosec
---

There are hardware skimmers that collect card data when swiped but there can
also be code written that can skim cards in an online checkout screen using
code injection techniques. There was this incident where a group of hackers got
access to a Magneto site and they modified a js library used in the checkout
page and added a skimming code that would capture the card data entered in the
forms of the page and send it to their servers. 

This also bring to attention the security vulnerabilities you get exposed to
when you use libraries and code that someone else wrote. What if the CDN you
were pulling a js library was compromised and the source code now contained
some malicious code. This was discussed in [this episode][1] of darknet diaries

[1]: https://darknetdiaries.com/episode/52 

