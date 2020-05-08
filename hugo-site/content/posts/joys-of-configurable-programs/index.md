---
title: "The joys of configurable programs like vim and i3"
date: 2019-12-02T14:15:30+05:30
description: "I go through how i3 and vim can be used to setup a custom workspace for working with NS (network simulator) and Nam (network animator)"
tags:
- i3
- vim
- workflow
---

I see configurable software like vim and i3 really good tools to work with. I
strongly believe you should have control over how something works in your
toolset. Tools like vim and i3 allow for users to customize their workings in
order fit their needs - this is what makes them so powerful and a joy to use.
There are many instances where one feels the need to tweak their tools so that
they could do things which would make their lives a little more easier. Most of
the times these are small ad-hoc tweaks and this is where programs like vim and
i3 shine.

One such instance of being able to tweak something was when I was working with
NS (network simulator) and preparing for my Computer Networks Lab exams. NS is
a network simulator and is built as a Tcl framework. It allows you to simulate
networking events like sending TCP traffic or pinging a host, etc. A simulation
is run using the `ns <tcl-script>` command. This runs the simulation and also
creates a `.nam` file that can be fed to NAM.  NAM is a Tcl/TK based animation
tool for viewing network simulation traces and real world packet traces.

Now for our lab work, we were supposed to make the topography of a network and
run the simulation, and to visualize it, we were supposed to use NAM. This
becomes a cumbersome task - first, to run the tcl script using the `ns`
command; then, run `nam output.nam`. Now, do this every time you want to see the
changes take effect to the animation. All of this can simply be "automated".

First I add a small keybind to vim to run `ns` on the tcl script that is
currently being edited.

```
nnoremap <leader>n:!ns %<Enter>
```

I have set my leader key as `,` (comma). When I press `,+n` ns is called and
the argument passed to it is the current file's name that is being edited, that
is what "`%`" stands for. This then produces the nam file. The same tcl script
also has a "finish" procedure that is called at the end.

```
proc finish {} {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam out.nam &
    exit 0
}
```

Here the line `exec nam out.nam &` calls the nam command.

So now I can just press `,+n` and the animation window comes up.  Now there's
another problem. The Nam window spawns another annoying small window that
serves no purpose but to display the version and some copyright info, and if
you close it, the main animation window gets closed as well.

{{< figure src="annoying-window.png" title="The annoying Nam window" width="40%" >}}

Both theses windows open as normal windows in i3 and hence get tiled which is
again annoying as it messes up my terminal.

{{< figure src="before-configuring.png" title="Before configuring i3" width="90%" >}}

Instead of having the main window tiled I would like it to be floating to the
right side of the screen. As for the unwanted window, I would like it to be
moved out of sight. This is where I can configure i3 to manage the windows. I
can configure i3 such that the unwanted window is moved to a scratchpad
workspace which is basically just a hidden workspace. And the main window can
be moved to the side of the screen and floating instead of tiling. The
following lines in the i3 config do the job.

```
for_window [title="Nam Console v1.15"] floating enable move scratchpad
for_window [title="nam: (?i)"] floating enable resize set 800 720, move position 560 25
```

Custom rules can be applied to a window depending on their title and other
attributes as well. To find the title you can use the `xwininfo` tool. So for
any window that has a title "Nam Console v1.15" (which is the unwanted window),
i3 will move it the scratchpad workspace, out of sight. And for the main
animation window titled "nam <filename.nam>", i3 will set the window to float,
reisze it to 800x720 and move to position x=560 and y=25 on the screen.

{{< figure src="after-configuring.png" title="After configuring i3" width="90%" >}}

This was a small instance where good configurable tools, with a few lines of
configuration (literally three lines in this case) can make a huge impact on
work flow and productivity.
