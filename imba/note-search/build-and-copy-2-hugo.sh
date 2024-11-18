#!/bin/bash

NOTES_LIST_HTML=/home/prithu/src/website/layouts/notes/list.html
npm run build
rsync --delete -av dist/assets/ /home/prithu/src/website/static/assets
ls dist/assets/*js | xargs basename | xargs -I{} sed -i s/main.*\.js/{}/ $NOTES_LIST_HTML
ls dist/assets/index*.css | xargs basename | xargs -I{} sed -i s/index.*\.css/{}/ $NOTES_LIST_HTML
