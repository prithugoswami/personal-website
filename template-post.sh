#!/usr/bin/bash

postc=$(cat "$1")

cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>

  <meta charset="utf-8">
  <title>Prithu Goswami</title>
  <meta name="description" content="Prithu Goswami's personal website">
  <meta name="author" content="Prithu Goswami">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link href="https://fonts.googleapis.com/css?family=Roboto+Mono:300,400,700" rel="stylesheet"> 
  <link rel="stylesheet" href="/css/main.css">
  <link rel="stylesheet" href="/css/blog.css">
  <link rel="icon" type="img/png" href="/img/favicon.png">

</head>

<body>
  <p class="wip">WIP</p>
  <nav>
    <ul>
      <li><a href="/">About me</a></li>
      <li><a href="/projects">Projects</a></li>
      <li><a href="/blog.html">Blog</a></li>
      <li><a href="/links">Links</a></li>
    </ul>
  </nav>

  <div class="bcontainer">
    <div class="bcontent">
      <h1>Post title goes here </h1>
      <p class="post-date">Januaray 19, 2019</p>
      <div class="post-labels">
      $( for a in tag1 tag2 tag3
  do
    echo "<div class=post-label>$a</div>"
  done
      )
        <div class=post-label>Linux</div>
      </div>
      <div class="post-text">
      $postc
      </div>
    </div>
  </div>

</body>

</html>
EOF
