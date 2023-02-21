" Startify
let g:startify_change_to_dir = 0
let g:startify_fortune_use_unicode = 1
let g:startify_session_dir = '~/.cache/vim/session'
let g:startify_session_persistence = 1
let g:startify_session_before_save = [
\   'echo "Cleaning up before saving.."',
\   'silent! NERDTreeTabsClose',
\   'silent! NERDTreeClose',
\   'silent! Vista!',
\ ]
let g:startify_bookmarks = []
let g:startify_lists = [
\ { 'type': 'files',     'header': ['   Files']            },
\ { 'type': 'sessions',  'header': ['   Sessions']       },
\ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
\ ]
