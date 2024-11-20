---
title: make lambda.zip using python poetry
date: 2024-03-07T21:04:00Z
slug: make-lambda-zip-using-python-poetry
tags:
- python
- aws
---

```
poetry build
poetry run pip install --upgrade -t dist/lambda dist/reporter*.whl
cd dist/lambda; zip -r ../lambda.zip . -x '*.pyc'; cd ../../
``` 


- If there are problems with some dependencies (GLIBC version mismatch) use
  `--platform manylinux2014_x86_64` (or another type of linux pypi package) and
  `--only-binary=:all:`

  ```
  poetry run pip install --platform manylinux2014_x86_64 --only-binary=:all: -t dist/lambda dist/reporter*.whl

  ```

## without poetry
```
pip install --platform manylinux2014_x86_64 --only-binary=:all: -r requirements.txt -t /build/lambda

# add your python package /build/lambda

cd /build/lambda; zip -r /build/lambda.zip . -x '*.pyc'; cd ../../

```
