---
title: playwright is really good for browser automation
date: 2022-05-01T01:31:00Z
slug: playwright-is-really-good-for-browser-automation
tags:
- automation
- webdev
---

[playwright](https://playwright.dev/docs/intro) is really good for browser
automation. It is a re-write of puppeteer, I believe, and is maintained by the
same devs and has tons of improvements, maybe because it was
supported/sponsored by microsoft.

It also has a wonderful feature of automatically recording your actions and
converting them to a script. Running this would open a browser window and you
can then record your actions.

```shell
npx playwright codegen https://netbanking.hdfcbank.com/netbanking/
```

