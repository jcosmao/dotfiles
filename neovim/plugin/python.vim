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
        let l:gitroot = trim(system('git -C ' . expand('%:h') . ' rev-parse --show-toplevel 2> /dev/null'))

        if l:gitroot != ''
            let l:maxlinelen = trim(system('cd '.l:gitroot. "; grep max-line-length pyproject.toml tox.ini 2> /dev/null | awk -F= '{print $2}' | tail -1"))
            if l:maxlinelen != ''
                exe 'set colorcolumn='.l:maxlinelen
                return
            endif

            " Force 79 char max for openstack projects
            if filereadable(l:gitroot . '/.gitreview')
                set colorcolumn=79
                return
            endif
        endif
    endif

    " reset colorcolumn
    set colorcolumn=
endfunction

autocmd FileType python command! -nargs=0 Black :call PythonBlack()
autocmd BufReadPost * call AutoColorColumn()
