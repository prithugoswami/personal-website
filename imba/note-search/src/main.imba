import search from './assets/img/search.svg'

def fetchNote slug
	let res = await window.fetch("./{slug}/index.json")
	try
		return await res.json!
	catch
		return null

tag note-content
	css h2 mb:4

	def routed params, state
		note = state.note ||= await fetchNote params.slug
		p = document.createElement('p')
		p.classList.add "post-text"
		p.innerHTML = note ? note.content : ""

	<self [o@suspended:0.4]>
		(<h2> note.title
		p) if note
			

tag note-item
	prop note
	css pl:4 pr:4
		my:10px

	css
		a@hover text-decoration: underline
		a c:warm3
			fw.active: 600
			c.active: white
	<self>
		<a route-to="/notes/{note.url.split('/').slice(-2,-1)}"> note.title

tag app
	target
	notes = []
	introBox
	searchQuery
	css d:flex jc:center x:-180px

	css .left d:vflex ai:left jc:start gap:2 w:296px mr:16 max-height:calc(100vh - 36px - 112px) pos:sticky top: 36px
	css .note-list ofy:scroll
		overscroll-behavior: none

	css .center w:664px

	css
		input bgc:transparent outline:none bd:none c:white/80 p:0 w:100% 
		.searchbar bgc:white/15 bd:none d:hflex px:4 py:1 rd:3 gap:2 mb:2
		.center h2 mb:4

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
				<svg src=search width=18px>
				<input bind=searchQuery>
			<div.note-list.vert-scroller @scroll.log("c")>
				for note in notes
					if !searchQuery
						<note-item note=note>
					else
						<note-item note=note> if note.title.toLowerCase!.indexOf(searchQuery) >= 0
		<div.center>
			<div route="/notes/">
				<h2> "Notes"
				introBox
			<note-content route="/notes/:slug">


var root = document.getElementById '_search_app_target'
var placeholder = document.getElementById '_search_app_placeholder'
let appc = <app target=root>
if root
	imba.mount appc, placeholder
else
	console.log("no element with _search_app id found")
