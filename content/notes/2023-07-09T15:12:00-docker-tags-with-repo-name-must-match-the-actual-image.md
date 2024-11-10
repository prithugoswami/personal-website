---
title: docker tags with repo name must match the actual image
date: 2023-07-09T15:12:00Z
slug: docker-tags-with-repo-name-must-match-the-actual-image
tags:
- docker
- containers
---


These are not the same
  ```
docker tag api-service:latest 123456789012.dkr.ecr.eu-west-1.amazonaws.com/api:latest
docker push 123456789012.dkr.ecr.eu-west-1.amazonaws.com/api:latest
```

```
docker tag api-service:latest 123456789012.dkr.ecr.eu-west-1.amazonaws.com/api-service:latest
docker push 123456789012.dkr.ecr.eu-west-1.amazonaws.com/api-service:latest
```

Maybe this is obvious for future me. But this is the stupid thing I was doing expecting the first command to work when I docker pushed. Need to further investigate what was actually being pushed in the first case?

