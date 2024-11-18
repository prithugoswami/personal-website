SHELL=/bin/bash -o pipefail

default: build-hugo

build-imba:
	cd imba/note-search && \
	npm ci && \
	npm run build && \
	cp -r dist/assets ../../static/ && \
	ls dist/assets/*js | xargs basename | xargs -I{} sed -i s/main.*\.js/{}/ ../../layouts/notes/list.html && \
	ls dist/assets/index*.css | xargs basename | xargs -I{} sed -i s/index.*\.css/{}/ ../../layouts/notes/list.html

build-hugo: build-imba
	hugo build

