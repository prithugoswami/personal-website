import search from './assets/img/search.svg'
import menu from './assets/img/menu.svg'

def fetchNote slug
	let res = await window.fetch("./{slug}/index.json")
	try
		return await res.json!
	catch
		return null

tag note-content
	css h2 mb:4 c:$text-primary
	css c:$text

	def routed params, state
		emit("noteChanged")
		note = state.note ||= await fetchNote params.slug
		p = document.createElement('p')
		p.classList.add "post-text"
		p.innerHTML = note ? note.content : ""

	<self [o@suspended:0.4 tween: all 75ms ease]>
		(<h2> note.title
		<p[c:$text my:3]> note.date
		<div.post-labels>
			if note.tags
				for t in note.tags
					<p.post-label> t
		p) if note
			

tag note-item
	prop note
	css pl:4 pr:4
		my:10px

	css
		a@hover text-decoration: underline
		a c: $text
			fw.active: 600
			c.active: $text-primary
	<self>
		<a route-to="/notes/{note.url.split('/').slice(-2,-1)}"> note.title

tag app
	target
	notes = []
	introBox
	searchQuery
	navOpen? = false
	css d:grid grid-template-columns: repeat(28, 1fr) m: 0px auto w: auto w:1344px
		w@!1368: 95%
		w@!768: 90%

	css .left	
		o: 0.3 @hover: 1
		d:vflex ai:left jc:start grid-column: 1 / 7 max-height:calc(100vh - 96px - 112px) min-height:80 pos:sticky top: 96px
		gap: 2
		tween: all 200ms ease
		min-width: 240px
		@!768
			zi: 150
			height: 100vh
			max-height: 100vh
			o: 1
			x: -100vw
			grid-row: 1 / -1
			bgc: $bg
			p: 5
			w: 80vw
			box-shadow: 0 3px 12px rgba(0,0,0,0.1)
			
	css .note-list ofy:scroll
		overscroll-behavior: none

	css .center
		max-width: 672px
		grid-column: 8 / 22
		grid-column@!1368: 8 / 28
		@!768
			grid-column: 1 / -1
			grid-row: 1 / -1


	css
		input bgc:transparent outline:none bd:none c:$text p:0 w:100% 
		.searchbar bgc:$card-bg d:hflex px:4 py:1 rd:3 gap:2 mb:2
			olc:$imba-searchbar-outline-color olw:$imba-searchbar-outline-width ols:$imba-searchbar-outline-style
		.center h2 mb:4

	def escapeRegExp(str)
		str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

	def fuzzyMatch(query, string)
		pattern = query.trim().split(' ').map(do(l) "{escapeRegExp(l)}").join("|");
		const re = new RegExp(pattern, "i")
		return re.test(string)


	def setup
		for c in target.children
			if c.id == 'notes-list'
				for n in c.children
					anchor = n.children[0]
					let note = {}
					note.title = anchor.innerHTML
					note.url = anchor.href
					notes.push note
			elif c.className == 'intro-text'
				introBox = c
			imba.unmount target
		nav = document.querySelector("nav")
		nav.id = "notes-nav"
		const div = <div [
			d:hflex
			jc:space-between grid-column: 8 / 22 grid-column@!1368: 8 / 28
			max-width: 672px
			@!768
				grid-column: 2 / -1
		]>
		const divl = <div [
			grid-column: 1 / 7
			min-width: 240px
			@!768
				d: none
				
		]>
		while nav.firstChild
			div.appendChild(nav.firstChild)
		menuSvg = <svg src=menu width=24px [fill:$text d:none d@!768: block mr:4] @click=(navOpen? = !navOpen?)>
		nav.appendChild divl
		nav.appendChild menuSvg
		nav.appendChild div

	<self>
		<div.left [x@!768:-5vw]=navOpen?>
			<div.searchbar>
				<svg src=search width=18px [fill:$text]>
				<input bind=searchQuery>
			<div.note-list.vert-scroller>
				for note in notes
					if !searchQuery
						<note-item note=note>
					else
						// <note-item note=note> if note.title.toLowerCase!.indexOf(searchQuery) >= 0
						<note-item note=note> if fuzzyMatch(searchQuery, note.title)
		if navOpen?
			<div [
				w:100% h:100% zi:149 grid-column: 1 grid-row: 1 position: absolute top:0px left:0px
			] @touch=(navOpen? &&= false) @click=(navOpen? &&= false)>
		<div.center @click=(navOpen? &&= false)>
			<div route="/notes/">
				<h2[c:$text-primary]> "Notes"
				introBox
			<note-content @noteChanged=(navOpen? &&= false) route="/notes/:slug">


var root = document.getElementById '_search_app_target'
var placeholder = document.getElementById '_search_app_placeholder'
let appc = <app target=root>
if root
	imba.mount appc, placeholder
else
	console.log("no element with _search_app id found")
