---
title: AWS Resource policies
date: 2022-07-09T15:20:00Z
slug: aws-resource-policies
tags:
- aws
---

- There are two ways to manage access of a bucket - user policies or resources
  policies. Access policies that you attach to your resources (buckets and
  objects) are referred to as resource-based policies. You can also attach
  polcies to your users in your account, called user policies. 
- Resources policies are attached to the resource (in s3 for eg. buckets or
  even objects). Resource policy dictates who is allowed to access the resource

## Principals

`Principal` element is used in resource-based policies. The Principal element
specifies the user, account, service, or other entity that is allowed or denied
access to a resource.


## Read more
- https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html

