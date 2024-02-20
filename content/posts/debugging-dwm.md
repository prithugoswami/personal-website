---
title: "Debugging dwm to fix an annoying bug"
date: 2024-02-17T18:19:23+05:30
description: "Going through the source code of dwm written in C and debugging it using gdb to fix an annoying issue."
---

I use [dwm](https://dwm.suckless.org) as my window manager and I always wanted
to hack on it ever since I started using it and I have taken my first step
towards that by debugging it and understanding the codebase a little. This post is
just going to be a lot of snippets from dwm source code with my explanation on
it as I understand it myself and sharing what I learnt while debugging dwm
along the way. I wanted to fix an annoying issue I was facing with dwm and
through this post I want to document the process of how I fixed it. It's also a
reason for me to practice writing.

The annoying issue that I was facing with my dwm setup was related to a scratchpad patch. I use a scratchpad terminal using the [scratchpad patch](https://dwm.suckless.org/patches/scratchpad/) which gives me an extra tag called the scratchpad tag where I can have a floating terminal window wherever I want.

Like this:


{{< video src="https://m.prithu.dev/dwm-debug-1-scratchpad-demo.mp4" type="video/mp4" loop=true autoplay=true >}}

I have [nnn](https://github.com/jarun/nnn) running in a tmux window (I usually
have a tmux session called `scratchpad` for this) which let's me quickly browse and open
files. I also have other tmux windows for quick commands or to note down
something.

{{< aside >}}

### A little about dwm tags

DWM has the concept of "tags" and not workspaces. Those numbers on the top-left are tags. A window can be part of one or more tags. It's a little confusing when coming from other window managers, where the numbers represent workspaces, but this concept makes sense once you start using it. For example, let's say I have  a browser window on tag 2 and 4, so when I move from 2 to 4 the browser window appears on both the tags. DWM also allows you to look at two tags at the same time. Which means all the windows in tag 2 and 4 appear together on a single screen.

{{< /aside >}}

## The Problem

Now, the problem is when I launch programs from the `scratchpad` (say a video player), they stick around in the scratchpad tag too, which shouldn't happen. This means that the video player window has the tags `1` and `6` set (6 is the internal number for the scratch tag). Now when I move to another tag, say `2` (Note: there is no such thing as "moving" to another tab, just that you set a tag visible or invisible) and open the scratchpad there (make `scratch` tag visible) the video player appears there as well. This is pretty annoying. The expected behaviour for me is I want the scratchpad to launch GUI applications on the tag "behind" the scratchpad (i.e the other tag that is visible along with the scratchpad) and not in the scratchtag itself.

Here's a video of the problem (You can see how frustrated I am by the chaotic mouse movement at the end):

{{< video src="https://m.prithu.dev/dwm-debug-2-scratchpad-problem.mp4" type="video/mp4" loop=true autoplay=true >}}

The problem also occurred when I launch directly from the terminal like `mpv file.mp4 &`. So it wasn't something funny `nnn` was doing.

This is when I decided to read the [source code of dwm](https://git.suckless.org/dwm/files.html). My first intuition was that I will have to look at the code that handles new windows being opened in the X server and how dwm handles them. 


## Reading the source code

```c
int
main(int argc, char *argv[])
{
	if (argc == 2 && !strcmp("-v", argv[1]))
		die("dwm-"VERSION);
	else if (argc != 1)
		die("usage: dwm [-v]");
	if (!setlocale(LC_CTYPE, "") || !XSupportsLocale())
		fputs("warning: no locale support\n", stderr);
	if (!(dpy = XOpenDisplay(NULL)))
		die("dwm: cannot open display");
	checkotherwm();
	setup();
#ifdef __OpenBSD__
	if (pledge("stdio rpath proc exec", NULL) == -1)
		die("pledge");
#endif /* __OpenBSD__ */
	scan();
	run();
	cleanup();
	XCloseDisplay(dpy);
	return EXIT_SUCCESS;
}

```

Starting from the `main()` function We see some argument checks, a check if we can even open the X display, a check for another wm running, etc. Then some function calls: 
- `setup()` - sets up things for dwm to start as an X client itself, defining window attributes for itself, creating a window and bunch of other things.
- `scan()` - Scans the X server for all windows there are. It goes through every window using the [`XQueryTree()`](https://tronche.com/gui/x/xlib/window-information/XQueryTree.html) function and calls [`manage()`](#the-manage-function) for each window it finds. This is when I skim through `manage()` a little. It seems to me in the first read that this function is actually responsible for "registering" an X window as a "client" of dwm. OK, we'll come back to this later.
- `run()` - function which is nice and small and has the main event loop. Let's explore this further keeping in mind we want to find out how dwm handles new windows being spawned:


```c
void
run(void)
{
    XEvent ev;
    /* main event loop */
    XSync(dpy, False);
    while (running && !XNextEvent(dpy, &ev))
        if (handler[ev.type])
            handler[ev.type](&ev); /* call handler */
}
  ``` 


`handler` is an array of function pointers that maps an XEvent type (an int) to a function that handles an [`XEvent`](https://tronche.com/gui/x/xlib/events/structures.html) of that type. This is when I started reading a bit more about [X](https://x.org) and [Xlib](https://tronche.com/gui/x/xlib/).
``` c
static void (*handler[LASTEvent]) (XEvent *) = {
	[ButtonPress] = buttonpress,
	[ClientMessage] = clientmessage,
	[ConfigureRequest] = configurerequest,
	[ConfigureNotify] = configurenotify,
	[DestroyNotify] = destroynotify,
	[EnterNotify] = enternotify,
	[Expose] = expose,
	[FocusIn] = focusin,
	[KeyPress] = keypress,
	[MappingNotify] = mappingnotify,
	[MapRequest] = maprequest,
	[MotionNotify] = motionnotify,
	[PropertyNotify] = propertynotify,
	[ResizeRequest] = resizerequest,
	[UnmapNotify] = unmapnotify
};

```
To me, the ones that seemed of interest were `Expose`, `MappingNotify`, `MapRequest`. I looked up what each of them meant from the docs - [XEvents](https://tronche.com/gui/x/xlib/events/types.html). `Expose` is an event produced when a part of window is visible. `MappingNotify` seems like something related to keyboard/pointer mapping, which is unrelated to windows spawning. At this point I had read a little about how one creates a window and "maps" it in X. X refers to Mapping a window as the actual process of drawing it on the screen. You can create a window, but not displayed yet. A call to `XMapWindow()` is what makes the window visible on the screen. From the [docs](https://tronche.com/gui/x/xlib/window/XCreateWindow.html) of `XCreateWindow()`:

> The created window is not yet displayed (mapped) on the user's display. To display the window, call XMapWindow().

And if you read further in the docs of `XMapWindow()` you find the XEvent [`MapRequest`](https://tronche.com/gui/x/xlib/events/structure-control/map.html) mentioned

> The X server can report MapRequest events to clients wanting information about a different client's desire to map windows

That's it! DWM "subscribes" to this event because it wants to know which windows it needs to be managing. Now, need to look at what `maprequest` handler does:


```c
void
maprequest(XEvent *e)
{
	static XWindowAttributes wa;
	XMapRequestEvent *ev = &e->xmaprequest;
	Client *i;
	if ((i = wintosystrayicon(ev->window))) {
		sendevent(i->win, netatom[Xembed], StructureNotifyMask, CurrentTime, XEMBED_WINDOW_ACTIVATE, 0, systray->win, XEMBED_EMBEDDED_VERSION);
		resizebarwin(selmon);
		updatesystray();
	}

	if (!XGetWindowAttributes(dpy, ev->window, &wa))
		return;
	if (wa.override_redirect)
		return;
	if (!wintoclient(ev->window))
		manage(ev->window, &wa);
}
```
We see `manage()` here too! This function handles the `XMapRequestEvent` type. The `XMapRequestEvent` type has a window ID `window` which is accesses via `ev->window`.
The window ID and the window attributes of the new window are passed to `manage()`

The if block `if(!wintoclient(ev->window))` can be be read as - "If we don't already have this client being managed in one of the monitors then manage it".

```c
Client *
wintoclient(Window w)
{
	Client *c;
	Monitor *m;

	for (m = mons; m; m = m->next)
		for (c = m->clients; c; c = c->next)
			if (c->win == w)
				return c;
	return NULL;
}

```


Okay then! `manage()` is where it's at then. I mean, the clue is in the word "manage". It is a window "manager" we are dealing with after all. Before going into the `manage()` function, I'd like to mention the `Monitor` and `Client` structs.

### Monitor and Client structs

`Monitor` and `Client` are the main structs of the program. Monitors hold clients and a client is a representation of a window that dwm is currently managing.

Monitor struct:
```c
struct Monitor {
	char ltsymbol[16];
	float mfact;
	int nmaster;
	int num;
	int by;               /* bar geometry */
	int ty;               /* tab bar geometry */
	int mx, my, mw, mh;   /* screen size */
	int wx, wy, ww, wh;   /* window area  */
	unsigned int seltags; /* used to select which tagset is active */
	unsigned int sellt;
	unsigned int tagset[2]; /* a tagset represents tags as int set */
	int showbar, showtab, topbar, toptab;
	Client *clients;
	Client *sel;
	Client *stack;
	Monitor *next;
	Window barwin;
	Window tabwin;
	int ntabs;
	int tab_widths[MAXTABS];
	const Layout *lt[2];
};
```

Client struct:

```c
struct Client {
	char name[256];
	float mina, maxa;
	int x, y, w, h;
	int oldx, oldy, oldw, oldh;
	int basew, baseh, incw, inch, maxw, maxh, minw, minh;
	int bw, oldbw;
	unsigned int tags; /* The tags the client is assigned */
	int isfixed, isfloating, isurgent, neverfocus, oldstate, isfullscreen;
	int fakefullscreen;
	Client *next;
	Client *snext;
	Monitor *mon;
	Window win;
};
```

{{< aside >}}

### Global static variables 

There's `selmon` and `mons` global static variables that live throughout the
life-cycle of the program. They are one of the main variables of the program.
`selmon` points to the current selected monitor and `mons` points to the first
monitor. Each monitor points to the next monitor in a linked list fashion.


{{< /aside >}}


### The manage() function

Here are the first few lines of the function.

```c
void
manage(Window w, XWindowAttributes *wa)
{
	Client *c, *t = NULL;
	Window trans = None;
	XWindowChanges wc;

	c = ecalloc(1, sizeof(Client));
	c->win = w;
	/* geometry */
	c->x = c->oldx = wa->x;
	c->y = c->oldy = wa->y;
	c->w = c->oldw = wa->width;
	c->h = c->oldh = wa->height;
	c->oldbw = wa->border_width;

	updatetitle(c);
	if (XGetTransientForHint(dpy, w, &trans) && (t = wintoclient(trans))) {
		c->mon = t->mon;
		c->tags = t->tags;
	} else {
		c->mon = selmon;
		applyrules(c);
	}
// ...
// skipped lines
// ...
	c->bw = borderpx;

	if (!strcmp(c->name, scratchpadname)) {
		c->mon->tagset[c->mon->seltags] |= c->tags = scratchtag;
		c->isfloating = True;
		c->x = c->mon->wx + (c->mon->ww / 2 - WIDTH(c) / 2);
		c->y = c->mon->wy + (c->mon->wh / 2 - HEIGHT(c) / 2);
	}

	wc.border_width = c->bw;
	XConfigureWindow(dpy, w, CWBorderWidth, &wc);
// ...
// skipped lines
// ...
```

`manage()` gets a `Window` type (which is an `unsigned long` type underneath) which is an id of the window. It also gets a `XWindowAttributes` type which is a structure defining several attributes like `x`, `y` coordinates, `width`, `height`, `border_width`, etc.


We see that a new client structure gets allocated and its fields are populated with relevant info—some coming from `XWindowAttributes *wa` and some being calculated. At the end of the function we see a call to `attach(c)` which prepends the client to the linked list of clients of the monitor it's on. So this tells us the purpose of the function is indeed to create a client (which is just a window representation within dwm) and assign it to a monitor.

```c
void
attach(Client *c)
{
	c->next = c->mon->clients;
	c->mon->clients = c;
}

```



Down in this function I see this line `selmon->tagset[selmon->seltags] &= ~scratchtag;`. `selmon` is the current selected monitor and is a global static variable of `Monitor` type.

A `tagset` is an int set that uses an unsigned int and represents a set of the current selected tags of the monitor. Only one of the index of `tagset` is the current selected `tagset` which is pointed by `setltags` and the other is the previous set of selected tags.  This is to implement an Alt+Tab like functionality for switching between tags. `c->tags` is the set of tags the client is assigned to. The line `selmon->tagset[selmon->seltags] &= ~scratchtag;` is simply removing the scratchpad's tag from the tag set. `scratchtag` holds the value 32 (0b100000). I have 5 defined tags and scratchpad's tag is simply the 6th one. The line sounds to be as if telling we want to only have scratchpad in the scratchtag and no other window, which is also apparent by the lines that follow it: 

```c
    selmon->tagset[selmon->seltags] &= ~scratchtag;
	if (!strcmp(c->name, scratchpadname)) {
		c->mon->tagset[c->mon->seltags] |= c->tags = scratchtag;
		c->isfloating = True;
		c->x = c->mon->wx + (c->mon->ww / 2 - WIDTH(c) / 2);
		c->y = c->mon->wy + (c->mon->wh / 2 - HEIGHT(c) / 2);
	}

```
Only if the new window has a title of "scratchpad" (value of `scratchpadname`) do we allow it to have the scratchpad tag.
By removing the scratchpad tag before a new window is being mapped (wants to be displayed), the patch author made sure that the scratchtag is is not active when a new window comes in as we don't want any other window in the scrathtag other than the one that's named "scratchpad". It seems like the purpose of that line is exactly to prevent the problem I am facing—having a window spawn in the scratch tag when the scratchtag is active—why then does that still happen?

Now, this is a big function and you can understand only so much by just reading the code. We need to be able to debug it and be able to step over the code as dwm runs to learn more about what it does.


## Firing up the GNU debugger
 So I started looking at how we could debug dwm and I learnt about [Xephyr](https://wiki.archlinux.org/title/Xephyr). Xephyr is a nested X server that runs as an X application. It would allow me to start another X server and run dwm on it and then I could debug dwm.


Now to debug it we need to compile dwm with debugging enabled so that gdb can look up symbols and make debugging easy. Adding the `-g` in `CFLAGS` in `config.mk`:

```diff
-CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS}
+CFLAGS   = -g -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS}

```
and then running dwm in Xephyr using gdb:

```
$ Xephyr -br -ac -noreset -screen 800x600 :2 &
$ export DISPLAY=:2
$ make
$ gdb ./dwm
``` 

This would run dwm in the Xephyr X server as an X application. I think this is pretty cool!
Now as usual we can setup breakpoints and step through the code.

Here's a video of me reproducing the same problem with Xephyr and gdb

{{< video src="https://m.prithu.dev/dwm-debug-3-dwm-xephyr-gdb.mp4" type="video/mp4" loop=true autoplay=true >}}

### gdb session

First I want to confirm whether the new window being launched when the scratchpad is open, does have the scratchpad tag. From the Xephyr X instance, I open a scratchpad and run `eog ~/pictures/someimage.jpg` from the scratchpad terminal. I then send a SIGINT by pressing Ctrl-C in gdb window to get a gdb prompt. We can see now print the `selmon->clients->tags` value. Which will show us the tags of the last spawned window—the latest client managed under dwm. 

```
GNU gdb (GDB) 14.1
Copyright (C) 2023 Free Software Foundation, Inc.
Reading symbols from ./dwm...
(gdb) run
Starting program: /home/prithu/src/dwm/dwm


^C
Program received signal SIGINT, Interrupt.
0x00007ffff7cfff44 in poll () from /usr/lib/libc.so.6
(gdb) print(*selmon->clients)
$2 = {name = "20230903_153036.jpg", '\000' <repeats 236 times>, mina = 0, maxa = 0, x = 0, y = 16, w = 800, h = 584, oldx = 163, oldy = 43, oldw = 474, oldh = 514, basew = 360, baseh = 350, incw = 0, inch = 0, maxw = 0, maxh = 0,
  minw = 437, minh = 350, bw = 0, oldbw = 0, tags = 33, isfixed = 0, isfloating = 0, isurgent = 0, neverfocus = 0, oldstate = 0, isfullscreen = 0, fakefullscreen = 0, next = 0x55555564ae90, snext = 0x55555564ae90, mon = 0x5555555d0a40,
  win = 6291463}
(gdb) print(selmon->clients->tags)
$3 = 33

```



And yes, indeed we do see the value 33 (0b100001) which means that the client is on the scratchpad tag (0b100000) and tag 1 (0b000001). Now to find out why does that happen even though we have the line `selmon->tagset[selmon->seltags] &= ~scratchtag;` as a fail safe which makes sure we don't spawn any windows in the scratch tag? Well this is where stepping through the code line by line will help. We need to  check the value of `c->tags` and what changes it during the run.

### debugging manage()

```
~/src/dwm (mybuild) › gdb ./dwm
GNU gdb (GDB) 14.1
Copyright (C) 2023 Free Software Foundation, Inc.
Reading symbols from ./dwm...
(gdb) b dwm.c:1305
Breakpoint 1 at 0xa2c0: file dwm.c, line 1306.
(gdb) run
Starting program: /home/prithu/src/dwm/dwm

This GDB supports auto-downloading debuginfo from the following URLs:
  <https://debuginfod.archlinux.org>
Enable debuginfod for this session? (y or [n]) y
[Detaching after fork from child process 4106464]
```

I start a new debug session and set a breakpoint at the line `c = ecalloc(1, sizeof(Client));` in `manage()`. When a new window is created (mapped) by launching a GUI application, we should hit the breakpoint as dwm tries to add the window in the list of managed clients. I open a scratchpad and run `eog ~/pictures/someimage.jpg &` and we hit a breakpoint!


```

Breakpoint 1, manage (w=4194310, wa=0x555555564020 <wa>) at dwm.c:1306
1306            c = ecalloc(1, sizeof(Client));
(gdb) c
Continuing.
```

This breakpoint is hit when I launch the scratchpad for the first time. That's when the terminal window is created. Let's continue.
```

Breakpoint 1, manage (w=6291463, wa=0x555555564020 <wa>) at dwm.c:1306
1306            c = ecalloc(1, sizeof(Client));
(gdb) n
```
The second breakpoint is hit when I run `eog ~/pictures/somepic.jpg &`. This is when the image viewer window is created. The first line (1306) simply allocates space for the new client.
```
(gdb) display c->name
1: c->name = '\000' <repeats 255 times>
(gdb) display c->tags
2: c->tags = 0
(gdb) display selmon->tagset
3: selmon->tagset = {33, 2}
```
I use the `display` command here (Which I learnt in this process) to always print the values I am interested in after each line executes—`c->name` (Name of the client:X Window title), `c->tags`(The tags the client get's assigned, `selmon->tagset` (The current active tags of the current selected monitor: recall that the new window gets assigned the tags of the scratchpad and the tag that is active along with the scratchpad too)

```
1309            c->x = c->oldx = wa->x;
(gdb) n
1310            c->y = c->oldy = wa->y;
1: c->name = '\000' <repeats 255 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
(gdb) n
1311            c->w = c->oldw = wa->width;
1: c->name = '\000' <repeats 255 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
(gdb) n
1312            c->h = c->oldh = wa->height;
1: c->name = '\000' <repeats 255 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
(gdb) n
1313            c->oldbw = wa->border_width;
1: c->name = '\000' <repeats 255 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
```
In the above lines, the client gets assigned a few attributes like window position, height and width from the `XWindowAttributes`
```
(gdb) n
1315            updatetitle(c);
1: c->name = '\000' <repeats 255 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
(gdb) n
1316            if (XGetTransientForHint(dpy, w, &trans) && (t = wintoclient(trans))) {
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
```
After the `updatetitle(c)` we see that the name of the client changed. `updatetitle(c)` lives upto its name!

```
(gdb) n
1320                    c->mon = selmon;
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
```
`c->mon = selmon` assigns the monitor it goes on (which is the current monitor)

```
(gdb) n
1321                    applyrules(c);
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 0
3: selmon->tagset = {33, 2}
(gdb) n
1324            if (c->x + WIDTH(c) > c->mon->mx + c->mon->mw)
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {33, 2}
```
**And here we have it—our culprit!** After the call to `applyrules(c)` we have `c->tags` change its value to `33` (`0b100001`) which is the value of `selmon->tagset[selmon->seltags]` as well.

```
(gdb) n
1326            if (c->y + HEIGHT(c) > c->mon->my + c->mon->mh)
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {33, 2}
(gdb) n
1328            c->x = MAX(c->x, c->mon->mx);
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {33, 2}
(gdb) n
1330            c->y = MAX(c->y, ((c->mon->by == c->mon->my) && (c->x + (c->w / 2) >= c->mon->wx)
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {33, 2}
(gdb) n
1334            selmon->tagset[selmon->seltags] &= ~scratchtag;
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {33, 2}
(gdb) n
1335            if (!strcmp(c->name, scratchpadname)) {
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {1, 2}
```

We don't enter the scratchpad loop because this isn't a scratchpad window—it's the
 image viewer. The line `selmon->tagset[selmon->seltags] &= ~scratchtag` is
too late. The client has already been assigned the scratchpad tag.

```
(gdb) n
1342            wc.border_width = c->bw;
1: c->name = "20230903_153036.jpg", '\000' <repeats 236 times>
2: c->tags = 33
3: selmon->tagset = {1, 2}
(gdb)
...
...
```
And as I go through the whole function, I find that `c->tags` isn't changed anywhere else.


### applyrules(c) is the culprit
This function is what modifies the `c->tag` value in `manage()`. It takes `Client` type add modifies the client `c`—which I completely skipped over while reading the code. I didn't bother to look at what it did. But when I saw the value change, everything clicked! The `c->tags` value was being changed by `applyrules(c)` way before the line `selmon->tagset[selmon->seltags] &= ~scratchtag` is executed. I took a look at `applyrules(c)` but already guessed what it does. It is responsible for applying some rules to the new client but also adds tags to new clients, which I didn't suspect during my first read. 


```c
void
applyrules(Client *c)
{
	const char *class, *instance;
	unsigned int i;
	const Rule *r;
	Monitor *m;
	XClassHint ch = { NULL, NULL };
	c->isfloating = 0;
	c->tags = 0;
	XGetClassHint(dpy, c->win, &ch);
	class    = ch.res_class ? ch.res_class : broken;
	instance = ch.res_name  ? ch.res_name  : broken;

	for (i = 0; i < LENGTH(rules); i++) {
		r = &rules[i];
		if ((!r->title || strstr(c->name, r->title))
		&& (!r->class || strstr(class, r->class))
		&& (!r->instance || strstr(instance, r->instance)))
		{
			c->isfloating = r->isfloating;
			c->tags |= r->tags;
			for (m = mons; m && m->num != r->monitor; m = m->next);
			if (m)
				c->mon = m;
		}
	}
	if (ch.res_class)
		XFree(ch.res_class);
	if (ch.res_name)
		XFree(ch.res_name);
	c->tags = c->tags & TAGMASK ? c->tags & TAGMASK : c->mon->tagset[c->mon->seltags];
}

```


`applyrules()` does some rule matching which is a feature that comes default in dwm config, where you can specify rules for specific windows. For example, let's say you wanted the Gimp Window to always open in tag 2—that sort of thing. I don't have any rules setup for the eog file viewer so this shouldn't affect it? Right? But, in `applyrules(c)` we see that `c->tags` is actually set to 0 first and then at the very end (after gone through the rules), it actually sets the tags if `c->tags` isn't already set by any of rules. The line `c->tags = c->tags & TAGMASK ? c->tags & TAGMASK : c->mon->tagset[c->mon->seltags];` reads "If there are no tags set yet for this client, then set them to the same tagset the client's monitor has" so the client's tags equal `c->mon->tagset[c->mon->seltags]` and we know that `c->mon` is `selmon` from the caller function just before the call to `applyrules()`— `c->mon = selmon`. There's our problem!

## The solution

The solution is put this assignment `selmon->tagset[selmon->seltags] &= ~scratchtag` before the call to `applyrules()`. That's it!

All this effort just to get the following patch—I wish it was a little more complicated than just this :D


```diff
diff --git a/dwm.c b/dwm.c
index e20a4ba..591f38a 100644
--- a/dwm.c
+++ b/dwm.c
@@ -1309,14 +1309,15 @@ manage(Window w, XWindowAttributes *wa)
 	c->x = c->oldx = wa->x;
 	c->y = c->oldy = wa->y;
 	c->w = c->oldw = wa->width;
 	c->h = c->oldh = wa->height;
 	c->oldbw = wa->border_width;
 
 	updatetitle(c);
+	selmon->tagset[selmon->seltags] &= ~scratchtag;
 	if (XGetTransientForHint(dpy, w, &trans) && (t = wintoclient(trans))) {
 		c->mon = t->mon;
 		c->tags = t->tags;
 	} else {
 		c->mon = selmon;
 		applyrules(c);
 	}
@@ -1327,15 +1328,14 @@ manage(Window w, XWindowAttributes *wa)
 		c->y = c->mon->my + c->mon->mh - HEIGHT(c);
 	c->x = MAX(c->x, c->mon->mx);
 	/* only fix client y-offset, if the client center might cover the bar */
 	c->y = MAX(c->y, ((c->mon->by == c->mon->my) && (c->x + (c->w / 2) >= c->mon->wx)
 		&& (c->x + (c->w / 2) < c->mon->wx + c->mon->ww)) ? bh : c->mon->my);
 	c->bw = borderpx;
 
-	selmon->tagset[selmon->seltags] &= ~scratchtag;
 	if (!strcmp(c->name, scratchpadname)) {
 		c->mon->tagset[c->mon->seltags] |= c->tags = scratchtag;
 		c->isfloating = True;
 		c->x = c->mon->wx + (c->mon->ww / 2 - WIDTH(c) / 2);
 		c->y = c->mon->wy + (c->mon->wh / 2 - HEIGHT(c) / 2);
 	}
```

## What I learnt
- Don't hesitate to read the source code\
  I feel this is the biggest take away. Just in about 30-45 mins I was able to go from zero knowledge of how dwm worked to figuring out that the problem was in the `manage()` function. Also owing to the fact that dwm  has simple codebase, and that's the suckless philosophy—because of which someone like me who had last read and written C in college about ~5 years ago, was able to figure it out and make changes to it. It made me realise C doesn't have to be as daunting as it seemed in my head to be.
- Learnt that something like Xephyr exists, which is pretty cool!
- Learnt about [ptrace_scope](https://www.kernel.org/doc/Documentation/security/Yama.txt) again when I initially tried doing `gdb -p $(pgrep dwm)` in my main X session.
- picked up some more useful gdb commands.
- Reading dwm's source gave me the confidence to finally write new features and make changes which I wish it had.
