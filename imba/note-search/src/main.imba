import search from './assets/img/search.svg'

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
		note = state.note ||= await fetchNote params.slug
		p = document.createElement('p')
		p.classList.add "post-text"
		p.innerHTML = note ? note.content : ""

	<self [o@suspended:0.4]>
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
	css d:flex jc:center x:-180px

	css .left d:vflex ai:left jc:start gap:2 w:296px mr:16 max-height:calc(100vh - 96px - 112px) min-height:80 pos:sticky top: 96px
	css .note-list ofy:scroll
		overscroll-behavior: none

	css .center w:664px

	css
		input bgc:transparent outline:none bd:none c:$text p:0 w:100% 
		.searchbar bgc:$card-bg d:hflex px:4 py:1 rd:3 gap:2 mb:2
			olc:$imba-searchbar-outline-color olw:$imba-searchbar-outline-width ols:$imba-searchbar-outline-style
		.center h2 mb:4

	def escapeRegExp(str)
		str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

	def fuzzyMatch(query, string)
		pattern = query.split(' ').map(do(l) "{escapeRegExp(l)}").join("|");
		console.log(pattern)
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

	<self>
		<div.left>
			<div.searchbar>
				<svg src=search width=18px [fill:$text]>
				<input bind=searchQuery>
			<div.note-list.vert-scroller @scroll.log("c")>
				for note in notes
					if !searchQuery
						<note-item note=note>
					else
						// <note-item note=note> if note.title.toLowerCase!.indexOf(searchQuery) >= 0
						<note-item note=note> if fuzzyMatch(searchQuery, note.title)
		<div.center>
			<div route="/notes/">
				<h2[c:$primary-text]> "Notes"
				introBox
			<note-content route="/notes/:slug">


var root = document.getElementById '_search_app_target'
var placeholder = document.getElementById '_search_app_placeholder'
let appc = <app target=root>
if root
	imba.mount appc, placeholder
else
	console.log("no element with _search_app id found")
