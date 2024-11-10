---
title: python logging in aws lambda
date: 2024-03-07T21:34:00Z
slug: python-logging-in-aws-lambda
tags:
- python
---

```python
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logger = logging.getLogger()
logger.setLevel(level=LOG_LEVEL)


logger.info("Info log")
logger.info("Error log")
```

### Also see
- [amazon web services - Using python Logging with AWS Lambda - Stack Overflow](https://stackoverflow.com/questions/37703609/using-python-logging-with-aws-lambda)
