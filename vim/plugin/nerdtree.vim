let NERDTreeQuitOnOpen = 0
let NERDTreeShowHidden = 1
let NERDTreeShowBookmarks = 1
let NERDTreeWinSize = 40
let NERDTreeIgnore = ['.git[[dir]]', '.swp', '.pyc', '__pycache__', '.egg-info[[dir]]', 'pip-wheel-metadata[[dir]]']

function! PreventBuffersInNERDTree()
  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
    \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
    \ && &buftype == '' && !exists('g:launching_fzf')
    let bufnum = bufnr('%')
    close
    exe 'b ' . bufnum
  endif
  if exists('g:launching_fzf') | unlet g:launching_fzf | endif
endfunction

function! NERDTreeToggle()
    if exists("g:NERDTree") && g:NERDTree.IsOpen()
        NERDTreeClose
    elseif filereadable(expand('%'))
        NERDTreeFind
    else
        NERDTreeCWD
    endif
endfunction

function! NERDTreeRefresh()
    " focus on nerdtree or special buffer
    if (exists("b:NERDTree") || !filereadable(expand('%')))
        return
    elseif exists("g:NERDTree") && g:NERDTree.IsOpen()
        NERDTreeFind | wincmd w
    endif
endfunction

" autoclose if nerdtree is the last one
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
autocmd BufWinEnter * call PreventBuffersInNERDTree()
autocmd bufenter * call NERDTreeRefresh()
" autocmd User StartifyReady NERDTree | wincmd w
" autocmd User StartifyBufferOpened NERDTreeFind | wincmd w
