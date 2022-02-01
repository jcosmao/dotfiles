function! custom#PlugLoaded(name)
    return (
        \ has_key(g:plugs, a:name) &&
        \ isdirectory(g:plugs[a:name].dir))
endfunction

function! custom#GitInfo()
    let current_file_path = resolve(expand('%:p:h'))
    let git_repo = system("cd " . current_file_path . "; basename -s .git $(git remote get-url origin 2> /dev/null) 2> /dev/null")
    let git_branch = system("cd " . current_file_path . "; git rev-parse --abbrev-ref HEAD 2> /dev/null")
    let repo = substitute(git_repo, '\n\+$', '', '')
    let branch = substitute(git_branch, '\n\+$', '', '')
    if (repo != '')
        let g:lightline_git_info = " " . repo ." [" . branch . "]"
    else
        let g:lightline_git_info = ''
    endif
endfunction

function! custom#LightlineToggleBuffer()
    let disable_on_buffer = ["NvimTree", "__Tagbar__.1"]
    let current_buffer = bufname()
    if index(disable_on_buffer, current_buffer) >= 0
        call lightline#disable()
    else
        call lightline#enable()
    endif
endfunction

function! custom#HieraEncrypt()
    let git_root = split(system('git -C '.shellescape(expand("%:p:h")).' rev-parse --show-toplevel'), '\n')[0]
    if filereadable(git_root.'/ovh-hiera-encrypt')
        redir => message
        execute ':silent !'.git_root.'/ovh-hiera-encrypt -f '.shellescape(expand("%:p")) | execute 'redraw!'
        redir END
        execute ':silent edit!'
        echohl WarningMsg
        echo 'custom#HieraEncrypt: ' . message
        echohl None
    endif
endfunction

" autocmd BufWritePost *.yaml call custom#HieraEncrypt()

function! custom#ToggleMouse()
    " check if mouse is enabled
    if &mouse == 'a'
        " disable mouse
        set mouse=
    else
        " enable mouse everywhere
        set mouse=a
    endif
endfunction

function! custom#NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
