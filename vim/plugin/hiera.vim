function! HieraEncrypt()
    let git_root = split(system('git -C '.shellescape(expand("%:p:h")).' rev-parse --show-toplevel'), '\n')[0]
    if filereadable(git_root.'/ovh-hiera-encrypt')
        execute ':silent !'.git_root.'/ovh-hiera-encrypt -f '.shellescape(expand("%:p")) | execute 'redraw!'
        execute ':silent edit!'
        echohl WarningMsg
        echo 'HieraEncrypt(): done'
        echohl None
    endif
endfunction

autocmd BufWritePost *.yaml call HieraEncrypt()
