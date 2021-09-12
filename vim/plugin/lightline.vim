let g:lightline_git_info = ''
au BufEnter * call custom#GitInfo()
au BufEnter * call custom#LightlineToggleBuffer()

" lightline
let g:lightline = {
\   'colorscheme': 'gruvbox_material',
\   'active': {
\       'left': [
\           [ 'mode', 'paste' ],
\           [ 'gitrepo' ],
\           [ 'readonly', 'filename', 'modified', 'tagbar' ],
\       ],
\      'right': [
\           [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok', 'lineinfo' ],
\           [ 'percent' ],
\           [ 'fileformat', 'fileencoding', 'filetype' ],
\       ],
\   },
\   'component': {
\       'tagbar': '%{tagbar#currenttag("%s", "", "f")}',
\       'gitrepo': '%{g:lightline_git_info}',
\    },
\   'component_expand': {
\       'linter_checking': 'lightline#ale#checking',
\       'linter_warnings': 'lightline#ale#warnings',
\       'linter_errors': 'lightline#ale#errors',
\       'linter_ok': 'lightline#ale#ok',
\    },
\   'component_type': {
\       'linter_checking': 'left',
\       'linter_warnings': 'warning',
\       'linter_errors': 'error',
\       'linter_ok': 'left',
\   },
\   'tab': {
\       'active': [ 'tabnum', 'filename', 'modified' ],
\       'inactive': [ 'tabnum', 'filename', 'modified' ]
\   }
\}

" Autoset lightline colorsheme (except gruvbox-material which does not match)
if colors_name == 'gruvbox-material'
    let g:lightline.colorscheme = 'gruvbox_material'
else
    let g:lightline.colorscheme = colors_name
endif


" lightline-ale
let g:lightline#ale#indicator_checking = "\uf110 "
let g:lightline#ale#indicator_warnings = "\uf071  "
let g:lightline#ale#indicator_errors = "\uf05e  "
let g:lightline#ale#indicator_ok = "\uf00c "
