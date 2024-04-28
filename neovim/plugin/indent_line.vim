" Indent Line
let g:indentLine_enabled = 1
let g:indentLine_char = '▏'

set conceallevel=2
autocmd InsertEnter * setlocal conceallevel=0
autocmd InsertLeave * setlocal conceallevel=2

let g:indentLine_setConceal = 0
" default ''.
" n for Normal mode
" v for Visual mode
" i for Insert mode
" c for Command line editing, for 'incsearch'
let g:indentLine_concealcursor = ''
let g:indentLine_setColors = 0
