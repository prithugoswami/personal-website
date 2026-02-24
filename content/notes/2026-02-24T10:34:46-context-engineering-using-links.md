---
title: context engineering using links
date: 2025-10-25T16:04:46+05:30
slug: context-engineering-using-links
tags:
- llms
- context-engineering
---

I came across [this interesting post](https://mbleigh.dev/posts/context-engineering-with-links/). Some notes after reading it:

- Context engineering involves the process of activily making the context window work for the given task. Since LLMs have a bias to information close to the end of the context window, it's important to optimize for this and remove all noise as the conversation progresses.
- Fresh invocations of LLMs with context perform better than stale, long running conversation.
- Author reminds us of HATEOAS where we link resources in responses too. Example:

  ```
  GET /accounts/12345 HTTP/1.1
  Host: bank.example.com
  
  HTTP/1.1 200 OK
  
  {
      "account": {
          "account_number": 12345,
          "balance": {
              "currency": "usd",
              "value": 100.00
          },
          "links": {
              "deposits": "/accounts/12345/deposits",
              "withdrawals": "/accounts/12345/withdrawals",
              "transfers": "/accounts/12345/transfers",
              "close-requests": "/accounts/12345/close-requests"
          }
      }
  }

  ```
  Here we see that the to deposit into the account we can simply follow the deposits URI if we want to deposit into the account. This leads to auto-discovery of resources.
- Author suggests that we can provide similar linking strategy into the prompt of the LLM. An example
  ```
  { system: "Today's special is blueberry pie. " +
    "If the user needs help with a pet, read `instruction://pet-help`"
  }
  ```
  and then provide a tool like `read_resources` that take a list of URIs that can return those resources:

  ```js
  // static text in this example, but can be dynamically fetched/generated
  const RESOURCES = {
    "instruction://pet-help":
      "- for dog questions, read `instruction://pet-help/dogs`\n" +
      "- for cat questions, tell the user to get a dog instead.",
    "instruction://pet-help/dogs": "Feed them Barky(TM) brand pet food!",
  };
  
  const read_resources = ({ uris }) => {
    console.log("Read resources:", uris);
    return uris.map((uri) => RESOURCES[uri]
        // wrap in XML section blocks so the model can differentiate multiple URIs
        ? `<resource uri="${uri}">\n${RESOURCES[uri]}\n</resource>`
        : `<resource uri="${uri}" error>RESOURCE NOT FOUND</resource>`,
    ).join("\n\n");
  });
  ```
  *Note: I changed `prompt://` from the original to `instruction://`*

- We can also use this to link other types of resources like files, data, etc:
- Links are tool-efficient because they consolidate many types of reads into a single tool. You can have a data://me link that dynamically loads information about the current user, a `file://foo.md` link that loads a local file, and a `prompt://pet-help` link that returns static instructions. You don’t need a separate tool for each type of data.
- Links provide **just-in-time context** mitigating issues of context rot and recency bias in models. Because linked context is loaded when it’s needed by the model the context is “fresher” instead of overloading a system prompt.
