" Vim rooter
let g:rooter_patterns = ['.project/', '.project', '.git']
let g:rooter_resolve_links = 1

" Gutentag / ctags/cscope
"
" create .project dir in project root dir to build tags automatically
" by default, tags will be generated for all files in this root dir
" To override files list for tags generate, add executable in .project/file_list
" that should return files list
let g:gutentags_project_root = ['.project']
let g:gutentags_exclude_project_root = []
let g:gutentags_exclude_filetypes = [
\   'no ft', 'systemd',
\   'gitcommit', 'git', 'gitconfig', 'gitrebase', 'gitsendemail',
\   'cfg', 'conf', 'rst', 'dosini',
\   'sh', 'yaml', 'json', 'text'
\]
let g:gutentags_add_default_project_roots = 0
let g:gutentags_generate_on_empty_buffer = 0
let g:gutentags_resolve_symlinks = 1
let g:gutentags_modules = ['ctags', 'cscope']
let g:gutentags_ctags_executable = '~/.local/bin/ctags'
let g:gutentags_ctags_extra_args = ['--fields=+niaSszt --python-kinds=-vi --tag-relative=yes']
" rg --type-list
let g:gutentags_file_list_command = '/bin/true ; .project/file_list || rg --no-ignore --files -tsh -tperl -tpy -tgo -tcpp -tpuppet -tjson -tyaml'
let g:gutentags_scopefile = '.cscope.gutentags'
let g:gutentags_ctags_tagfile = '.ctags.gutentags'
let g:gutentags_ctags_exclude = [
\  '*.git', '*.svn', '*.hg',
\  'cache', 'build', 'dist', 'bin', 'node_modules', 'bower_components',
\  '*-lock.json',  '*.lock',
\  '*.min.*',
\  '*.bak',
\  '*.zip',
\  '*.pyc',
\  '*.class',
\  '*.sln',
\  '*.csproj', '*.csproj.user',
\  '*.tmp',
\  '*.cache',
\  '*.vscode',
\  '*.pdb',
\  '*.exe', '*.dll', '*.bin',
\  '*.mp3', '*.ogg', '*.flac',
\  '*.swp', '*.swo',
\  '.DS_Store', '*.plist',
\  '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png', '*.svg',
\  '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
\  '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx', '*.xls',
\]

" debug
" let g:gutentags_trace = 1
" let g:gutentags_debug = 1

" tagbar
let g:tagbar_map_showproto = '\'
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_previewwin_pos = "aboveleft"
let g:tagbar_autopreview = 0
let g:tagbar_ctags_bin = '~/.local/bin/ctags'

" autocmd BufWinEnter * if exists("b:gutentags_files") | call tagbar#autoopen(0) | endif

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
if s:current_file =~# '/tests/'
  let s:filter = "'/tests/ "
else
  let s:filter = "!/tests/ "
endif

command! -bang -nargs=* FZFCscope
  \ call fzf#run(fzf#wrap({
  \     'source': 'cscope -d -L -f '.b:gutentags_files['cscope'].' -0 '. shellescape(<q-args>).' | sed -e "s,^'.getcwd().'/,," | grep -Pv "\d+\s\s*(\#|:|\")" | grep -Pv "(class|def|func|function|sub) '.<q-args>.'"',
  \     'sink*': function('s:sink_cscope'),
  \     'options': '
  \         --query '.s:filter.'
  \         --prompt "Cscope ['.<q-args>.'] > "
  \         -1 -0 +i
  \         --exact
  \         --with-nth 1
  \         --nth 1
  \         --delimiter " "
  \         --preview-window "+{3}-15"
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
  \         --preview-window "+{5}-15"
  \         --preview "bat --color always --highlight-line {5} {2}"'
  \ }))

function! GoToDef(tag, ctx_line)
    let l:tag = a:tag
    let l:ctx_line = a:ctx_line

    " if &filetype == 'python'
    "     let r = execute(":call jedi#goto()")
    "     if r !~# "jedi-vim: Couldn't find any definitions"
    "         echo "GoToDef: jedi#goto()"
    "         return
    "     endif
    " endif

    if !exists("b:gutentags_files")
        echohl WarningMsg
        echo 'GoToDef(): Gutentags disabled'
        echohl None
        return
    endif

    if &filetype == 'puppet'
        " For puppet filetype, ctags are not generated with ^::
        let l:tag = trim(expand(a:tag), '^::')
    endif

    " Get matching tag list from ctags
    let tlist = taglist('^'.l:tag.'$')

    " For perl, keep only sub name (package_name::function)  a:ctx_line !~# '\(require\|package\|use\)'
    if &filetype == 'perl' && len(tlist) == 0
        let l:tag = substitute(expand(a:tag), '.*::\(.*\)', '\1', 'g')
        " Update taglist
        let tlist = taglist('^'.l:tag.'$')
    endif

    if len(tlist) == 0
        echohl WarningMsg
        echo 'GoToDef(): Tag ^'.l:tag.'$ not found'
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
map <silent> <C-]> :call GoToDef(expand('<cword>'), getline('.'))<cr>
map <silent> <leader>] :execute 'FZFCtags' '^'.expand('<cword>').'$'<cr>
map <silent> <leader>[ :execute 'tselect' expand('<cword>')<cr>

" autocmd FileType puppet nnoremap <C-]> call GoToDef(trim(expand('<cword>'), '^::'))
" autocmd FileType puppet nnoremap <leader>] :execute 'tag' trim(expand('<cword>'), '^::')<CR>

autocmd bufEnter *
\   if exists("b:gutentags_files") |
\       set csto=0 |
\       map <silent> <C-\> :execute 'FZFCscope' expand('<cword>') <CR> |
\   endif
