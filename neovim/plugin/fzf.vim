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


autocmd! FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
