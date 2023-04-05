" Semshi
let g:semshi#always_update_all_highlights = 1
let g:semshi#tolerate_syntax_errors = 1

" Black
function! Black()
    let l:opts = ""

    let l:is_openstack = system("find . -maxdepth 2 -name .gitreview | wc -l")
    if l:is_openstack > 0
        let l:opts = "-l 79"
    endif

    execute "!black " . l:opts . " " . expand('%:p')
    echo "[Black] done"
endfunction

autocmd FileType python command -nargs=0 Black :call Black()
