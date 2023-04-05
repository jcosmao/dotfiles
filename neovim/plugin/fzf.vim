" Fzf
let g:fzf_layout = { 'down': '~60%' }
let g:fzf_preview_window = ['right:hidden', '?']

let $FZF_DEFAULT_OPTS="--ansi --layout reverse --preview-window right:60% --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down --height=60% --margin 1,1"

" " Added --no-ignore
command! -bang -nargs=* Rg
    \ call fzf#vim#grep('rg --no-ignore --column --no-heading --line-number --color=always '.shellescape(<q-args>),
    \ 1,
    \ fzf#vim#with_preview({
    \   'options': '
    \       --delimiter ":"
    \       --exact
    \       --nth 4..'
    \ }),
    \ <bang>0)

command! -bang -nargs=* RgWithFilePath
    \ call fzf#vim#grep('rg --no-ignore --column --no-heading --line-number --color=always '.shellescape(<q-args>),
    \ 1,
    \ fzf#vim#with_preview({
    \   'options': '
    \       --exact'
    \ }),
    \ <bang>0)


autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'Macro'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Orange'],
  \ 'info':    ['fg', 'Aqua'],
  \ 'border':  ['fg', 'CursorLine'],
  \ 'prompt':  ['fg', 'Orange'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Orange'],
  \ 'spinner': ['fg', 'Aqua'],
  \ 'header':  ['fg', 'Aqua'] }
