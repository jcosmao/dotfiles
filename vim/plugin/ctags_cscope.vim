function s:sink_ctags(line)
    if empty(a:line)
      return
    endif

    let split = split(a:line[0], "\t")
    execute 'e ' . '+'.split[4].' '.split[1]  | execute 'call search("'.split[0].'", "", line("."))' | execute 'normal zz'
endfunction

function s:sink_cscope(line)
    if empty(a:line)
      return
    endif

    let l:search = expand('<cword>')
    let split = split(a:line[0], " ")
    execute 'e ' . '+'.split[2].' '.split[0] | execute 'call search("'.l:search.'", "", line("."))' | execute 'normal zz'
endfunction

let s:current_file = expand('%s')
if s:current_file =~# '/tests/unit/'
  let s:filter = "'/test/unit/ "
else
  let s:filter = "!/tests/unit/ "
endif

command! -bang -nargs=* FZFCscope
  \ call fzf#run(fzf#wrap({
  \     'source': 'cscope -d -L -f '.b:gutentags_files['cscope'].' -0 '. shellescape(<q-args>).' | sed -e "s,^'.getcwd().'/,," | grep -Pv "(class|def) '.<q-args>.'"',
  \     'sink*': function('s:sink_cscope'),
  \     'options': '
  \         --query '.s:filter.'
  \         --prompt "Cscope ['.<q-args>.'] > "
  \         -1 -0 +i
  \         --exact
  \         --with-nth 1
  \         --nth 1
  \         --delimiter " "
  \         --height=60%
  \         --preview-window "+{3}-15"
  \         --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down
  \         --color "preview-bg:235"
  \         --preview "bat --color always --highlight-line {3} {1}"'
  \ }))

command! -bang -nargs=* FZFCtags
  \ call fzf#run(fzf#wrap({
  \     'source': 'cat '.b:gutentags_files['ctags'].' | grep -v ^!_TAG | sed -e "s,\tline:,\t,g"',
  \     'sink*': function('s:sink_ctags'),
  \     'options': '
  \         --query '.shellescape(<q-args>).'
  \         --prompt "Ctags > "
  \         -1 -0 +i
  \         --exact
  \         --with-nth 1,4,2
  \         --nth 1
  \         --delimiter "\t"
  \         --height=60%
  \         --preview-window "+{5}-15"
  \         --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down
  \         --color "preview-bg:235"
  \         --preview "bat --color always --highlight-line {5} {2}"'
  \ }))

function! GoToDef(tag)
    let l:tag = a:tag

    if &filetype == 'python'
        let r = execute(":call jedi#goto()")
        if r !~# "jedi-vim: Couldn't find any definitions"
            echo "GoToDef: jedi#goto()"
            return
        endif
    endif

    if &filetype == 'puppet'
        " For puppet filetype, ctags are not generated with ^::
        let l:tag = trim(expand(a:tag), '^::')
    endif

    if !exists("b:gutentags_files")
        echohl WarningMsg
        echo 'GoToDef(): Gutentags disabled'
        echohl None
        return
    endif

    let tlist = taglist('^'.l:tag.'$')

    if len(tlist) == 0
        echohl WarningMsg
        echo 'GoToDef(): Tag not found'
        echohl None
        return 1
    elseif len(tlist) == 1
        execute 'tag' l:tag
        echo "GoToDef: tag"
    else
        execute 'FZFCtags' '^'.l:tag.'$'
        echo "GoToDef: FZFCtags"
    endif
endfunction


" Tag mapping ctags/cscope

" map <silent> <leader>] :execute 'tag' expand('<cword>')<CR>
map <silent> <C-]> :call GoToDef(expand('<cword>'))<cr>
map <silent> <leader>] :execute 'FZFCtags' '^'.expand('<cword>').'$'<cr>
map <silent> <leader>\ :execute 'tselect' expand('<cword>')<cr>

autocmd Filetype go nmap <C-]> <Plug>(go-def)
" autocmd FileType puppet nnoremap <C-]> call GoToDef(trim(expand('<cword>'), '^::'))
" autocmd FileType puppet nnoremap <leader>] :execute 'tag' trim(expand('<cword>'), '^::')<CR>

autocmd bufEnter *
\   if exists("b:gutentags_files") |
\       set csto=0 |
\       map <silent> <C-\> :execute 'FZFCscope' expand('<cword>') <CR> |
\   endif
