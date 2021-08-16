" Fzf
let g:fzf_layout = { 'down': '~60%' }
let g:fzf_preview_window = ['right:hidden', '?']

let $FZF_DEFAULT_OPTS="--ansi --layout reverse --preview-window right:60% --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down --height=60% --color preview-bg:234 --margin 1,4"

" " Added --no-ignore
command! -bang -nargs=* Rg
  \ call fzf#vim#grep('rg --no-ignore --column --no-heading --line-number --color=always '.shellescape(<q-args>),
  \ 1,
  \ fzf#vim#with_preview(),
  \ <bang>0)
