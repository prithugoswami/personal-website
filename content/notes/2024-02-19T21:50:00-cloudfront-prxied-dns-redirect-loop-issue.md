---
title: cloudfront proxied dns redirect loop issue
date: 2024-02-19T21:50:00Z
slug: cloudfront-prxied-dns-redirect-loop-issue
tags:
- cloudfront
- cloud
- troubleshoot
---

Faced an issue where I would get stuck in a redirect loop when configured a cloudflare dns as 'proxied'. Turns out the solution is to set SSL/TLS mode to 'Full' and that solves it.


# Ref
- https://community.cloudflare.com/t/enabling-cloudflare-dns-proxy-results-in-redirect-loop/510465

