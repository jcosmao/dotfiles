let g:lightline_git_info = ''
au BufEnter * call custom#GitInfo()
au BufEnter * call custom#LightlineToggleBuffer()
au VimEnter * call vista#RunForNearestMethodOrFunction()

" lightline
let g:lightline = {
\   'colorscheme': 'gruvbox_material',
\   'active': {
\       'left': [
\           [ 'mode', 'paste' ],
\           [ 'gitrepo' ],
\           [ 'readonly', 'filename', 'modified', 'method' ],
\       ],
\      'right': [
\           [  'lsp_info', 'lsp_hints', 'lsp_errors', 'lsp_warnings', 'lsp_ok', 'lsp_status', 'lineinfo' ],
\           [ 'percent' ],
\           [ 'fileformat', 'fileencoding', 'filetype' ],
\       ],
\   },
\   'component_function': {
\       'method': 'custom#NearestMethodOrFunction',
\   },
\   'component': {
\       'gitrepo': '%{g:lightline_git_info}',
\    },
\   'tab': {
\       'active': [ 'tabnum', 'filename', 'modified' ],
\       'inactive': [ 'tabnum', 'filename', 'modified' ]
\   }
\}

" register compoments:
call lightline#lsp#register()

" Autoset lightline colorsheme (except gruvbox-material which does not match)
if colors_name == 'gruvbox-material'
    let g:lightline.colorscheme = 'gruvbox_material'
else
    let g:lightline.colorscheme = colors_name
endif


" lightline-ale
let g:lightline#lsp#indicator_warnings = "\uf071  "
let g:lightline#lsp#indicator_errors = "\uf05e  "
let g:lightline#lsp#indicator_ok = "\uf00c "
