" NetRW
let g:netrw_liststyle = 3 "changes the directory tree style to style 3, press i to cycle through the styles temporarily
let g:netrw_banner = 0 "gets rid of the top banner
let g:netrw_winsize = -40 " negative == line ; positive == percent

function! s:ConfigureNetrw()
  nnoremap <buffer> <F1> :Lexplore<CR>
  nnoremap <buffer> ? :help netrw-quickmap<CR>
endfunction

augroup netrw_configuration
  autocmd!
  autocmd FileType netrw call s:ConfigureNetrw()
augroup end

function! WipeBuffer(name, id)
  let buffer_number = bufnr(a:name)
  execute 'bwipeout' buffer_number
endfunction

augroup WipeNetrw
  autocmd!
  autocmd BufHidden * if &ft == 'netrw' | call timer_start(100, function('WipeBuffer', [expand('<afile>')])) | endif
augroup END
