---
title: 'TIL: AWS Step functions are damn useful'
date: 2023-07-06T18:50:00Z
slug: til-aws-step-functions-are-damn-useful
---

At work, I was tasked to make a service that exports a good chunk of data
stored as delta tables on s3. We're talking 512MB - 2048 MB big parquet files
and it could take some time process it on our main AWS Lambda that runs a HTTP
API that cannot take too long to respond (not more than 10s). This task, to
export huge amounts of data, should be offloaded to another lambda. But how do
you coordinate and report errors? One way to coordinate this as a workflow is
by using AWS Step Functions

AWS Step funcions allows us to create workflows or state machines. Each state
can do something and go the next state. A state can also be a "Task" state. A
task state can invoke other aws services through their APIs- invoke a lambda,
or write something to a dynamodb table, etc. Each state gets an input and can
produce an output and transition to another state. Some types of states can
also transform their inputs and perform some basic limited functions. For
example if you wanted to transform an input json in some way (remove some keys
perhaps) you can use JSONPath to do that. ASL is what AWS calls the language
these states are written in and it's just extension of regular JSON with
support for JSONPath and some builin functions. There are also control flow
states that can take decissions and determine the flow of the state machine.
There is also something called map state, that let's you fan out your execution
and parallely run tasks.  AWS also provides a nice GUI workflow editor that you
can, with simple drag and drop primitives, create and edit these state
machines. Theres a lot of potential in making these starlte machines. It lets
you quickly glue together AWS services and also have a a nice overview of how
things flow and get executed. Oh, there's also error handling builtin, so you
can retry or catch errors and report them in anyway you like. Perhaps you have
a SQS queue specifically for errored jobs? Or would like to quickly send a
notification using SNS. Things like tbat...pretry powerful. Here's a great
example 

*insert diagram of a state and an example*
