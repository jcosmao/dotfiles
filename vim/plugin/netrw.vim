" NetRW
let g:netrw_liststyle = 3 "changes the directory tree style to style 3, press i to cycle through the styles temporarily
let g:netrw_banner = 0 "gets rid of the top banner
let g:netrw_winsize = -40 " negative == line ; positive == percent
let g:netrw_home=$HOME . 'cache/vim'

function! s:ConfigureNetrw()
  nnoremap <buffer> <F1> :call ToggleNetrw() <cr>
  nnoremap <buffer> ? :help netrw-quickmap <cr>
endfunction

augroup netrw_configuration
  autocmd!
  autocmd FileType netrw call s:ConfigureNetrw()
  autocmd FileType netrw setlocal bufhidden=wipe
augroup end

let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        if expand('%:p') ==? ''
            silent Lexplore
        else
            silent Lexplore %:h
        endif
    endif
endfunction
