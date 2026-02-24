---
title: {{ replace (substr .Name 20) "-" " " }}
date: {{ .Date }}
slug: {{ substr .Name 20 }}
tags:
---
