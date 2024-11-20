---
title: https for local development
date: 2024-03-07T08:31:00Z
slug: https-for-local-development
tags:
- ssl
- linux
---

- Use [mkcert](https://github.com/FiloSottile/mkcert)
  ```
  mkcert -install
  mkcert localhost # creates two localhost.pem (cert) and localhost-key.pem (key) file
  ```
- provide the key and cert file to the http server program. For example in python if using uvicorn:

  ```
  uvicorn.run("api.main:app", host="0.0.0.0", ssl_keyfile=key_path, ssl_certfile=cert_path, reload=True)
  ```
### Also read
  1. [How to Create Your Own SSL Certificate Authority for Local HTTPS Development](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)
  2. [How to Run HTTPS on Localhost: A Step-by-Step Guide](https://akshitb.medium.com/how-to-run-https-on-localhost-a-step-by-step-guide-c61fde893771)

