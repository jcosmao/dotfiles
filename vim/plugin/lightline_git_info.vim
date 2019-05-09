function! GitInfo()
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

let g:lightline_git_info = ''
au DirChanged,BufEnter * call GitInfo()
