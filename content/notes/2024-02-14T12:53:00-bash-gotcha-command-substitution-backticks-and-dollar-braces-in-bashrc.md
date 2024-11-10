---
title: A bash gotcha - command substitution in bashrc
date: 2024-02-14T12:53:00Z
slug: bash-gotcha-command-substitution-backticks-and-dollar-braces-in-bashrc
---

I have this alias in my bashrc:

```bash
alias qn="cd ~/docs/org/0-inbox/ && vim `date +%Y-%m-%d-%H%M`.md"
```

which uses Command-Substitution[^2] and basically just makes a "quick note" which I can refer later and move it
a more appropriate place in my organized notes when I have the time.
But when I run this alias it always opens the same note even if I run it at another time.

TIL that using \` (backticks) or even `$()` in alias this way makes it output
the value when the alias is initialized. So it essentially freezes it's value
when the alias is first sourced. So, If I run this command again at another
time it will still open the same file. Not what is intended.
The solution? Escape the command substitution

```
alias qn="cd ~/docs/org/0-inbox/ && vim \`date +%Y-%m-%d-%H%M\`.md"

```
Or
```
alias qn="cd ~/docs/org/0-inbox/ && vim \$(date +%Y-%m-%d-%H%M).md"
```

While I am at it let's not cd into the directory shall we?

```
alias qn="vim ~/docs/org/0-inbox/\$(date +%Y-%m-%d-%H%M).md"
```
### Also read
- [command substitution - Backticks vs braces in Bash - Stack Overflow](https://stackoverflow.com/questions/22709371/backticks-vs-braces-in-bash)


# Ref
[^2]:[Command Substitution (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html)
