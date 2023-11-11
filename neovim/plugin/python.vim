" Semshi
let g:semshi#always_update_all_highlights = 1
let g:semshi#tolerate_syntax_errors = 1

" Black
function! PythonBlack()
    let l:opts = ""

    let l:is_openstack = system("find . -maxdepth 2 -name .gitreview | wc -l")
    if l:is_openstack > 0
        let l:opts = "-l 79"
    endif

    execute "!black " . l:opts . " " . expand('%:p')
    echo "[Black] done"
endfunction

function! AutoColorColumn()
    if &filetype ==# 'python'
        let l:project_root = FindRootDirectory()
        let l:git_root = trim(system('git -C ' . expand('%:h') . ' rev-parse --show-toplevel 2> /dev/null'))

        if empty(l:project_root) && empty(l:git_root)
            return
        endif

        let l:maxlinelen = trim(system('grep max-line-length $(find '.l:project_root.' '.l:git_root.' -maxdepth 1 -name pyproject.toml -o -name tox.ini) | awk -F= "{print \$2}" | tail -1'))

        if !empty(l:maxlinelen)
            exe 'set colorcolumn='.l:maxlinelen
            return
        endif

        " Force 79 char max for openstack projects
        if filereadable(l:git_root . '/.gitreview')
            set colorcolumn=79
            return
        endif
    endif

    " reset colorcolumn
    set colorcolumn=
endfunction

autocmd FileType python command! -nargs=0 Black :call PythonBlack()
autocmd BufReadPost * call AutoColorColumn()
" Fix semshi color
autocmd BufWritePost,BufRead python execute 'Semshi enable'
