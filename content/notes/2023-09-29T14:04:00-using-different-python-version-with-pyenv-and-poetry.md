---
title: using different python version with pyenv and poetry
date: 2023-09-29T14:04:00Z
slug: using-different-python-version-with-pyenv-and-poetry
tags:
- python
---

1. install pyenv
2. install a python version using `pyenv install 3.9`
3. this should have created a directory `~/.pyenv`
4. tell poetry to use a specific python version - `poetry env use /home/prithu/.pyenv/versions/3.9.18/bin/python`
5. then run `poetry install`

