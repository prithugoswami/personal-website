---
title: access cloudflare r2 using aws cli
date: 2024-11-05T23:07:00Z
slug: access-cloudflare-r2-using-aws-cli
tags:
- cloudflare
- s3
---

1. Create R2 tokens from the r2 Overview page. "Manage r2 API Tokens" -> "Create API Token"
3. Copy the access key id and secret access key values
4. Copy the endpoint url. It's of the form `<cloudflare_account_id>.r2.cloudflarestorage.com`. Cloudflare account id is present in the url bar too when you are accessing the cloudflare dashboard and is also displayed in overview page of r2
4. ~/.aws/config:
   ```
   [profile cloudflare]
   endpoint_url = https://<cloudlare_account_id>.r2.cloudflarestorage.com
   ```
5. ~/.aws/credentials
   ```
   [cloudflare]
   aws_access_key_id = <> 
   aws_secret_access_key = <>
   ```
6. test with:
   ```
   aws s3 ls
   ```
