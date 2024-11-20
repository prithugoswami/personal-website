---
title: setting up cgit with nginx
date: 2022-04-28T00:27:00Z
slug: setting-up-cgit-with-nginx
tags:
- nginx
- linux
---

```nginx
server {
  server_name git.prithu.dev;
  listen 80;
  access_log /var/log/nginx/git.prithu.dev/access.log;
  error_log /var/log/nginx/git.prithu.dev/error.log;
    #auth_basic "Git Login";
    #auth_basic_user_file "/srv/git/.htpasswd";

  location /static {
    alias /var/www/cgit;
    try_files $uri =404;
  }

  location / {
    fastcgi_pass  unix:/run/fcgiwrap.socket;
    fastcgi_param SCRIPT_FILENAME /usr/lib/cgit/cgit.cgi;
    fastcgi_param PATH_INFO       $uri;
    fastcgi_param QUERY_STRING    $args;
  }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/git.prithu.dev/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/git.prithu.dev/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
```

