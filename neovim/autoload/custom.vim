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
    if bufname() =~# '^\v(NvimTree|term://|Trouble|OUTLINE|aerial)'
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

autocmd FileType yaml command! -nargs=0 HieraEncrypt :call custom#HieraEncrypt()

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


function! custom#backgroundToggle()
    if $THEME == "light"
        let $THEME = "dark"
        set background=dark
    else
        let $THEME = "light"
        set background=light
    endif

    let l:config_dir = $HOME."/.config/nvim/"
    let l:theme_dir = g:plugs['gruvbox-material']['dir']
    exec 'source '. l:config_dir .'/plugin/colors.vim'
    exec 'source '. l:config_dir .'/lua/config/toggleterm.lua'
    exec 'source '. l:theme_dir .'/autoload/lightline/colorscheme/gruvbox_material.vim'
    exec 'source '. l:config_dir .'/plugin/lightline.vim'
    exec 'NvimTreeToggle'
    exec 'NvimTreeToggle'
    exec 'call lightline#colorscheme() | call lightline#update()'
endfunction

autocmd FileType * command! -nargs=0 BackgroundToggle :call custom#backgroundToggle()


let g:custom_special_filtetypes = ['NvimTree', 'NvimTree_*', 'aerial', 'startify', 'fzf', 'Trouble',
    \                              'Mason', 'DiffviewFiles', 'toggleterm', 'toggleterm*']

function custom#isSpecialFiletype() abort
    let l:regexp = join(g:custom_special_filtetypes, '\|')
    if match(&ft, '^('.l:regexp.')$') == 0 || empty(&ft)
        return 1
    else
        return 0
    endif
endfunction

let g:custom_last_display_file_path = ""
function! custom#displayFilePath()
    if ! custom#isSpecialFiletype()
        if g:custom_last_display_file_path != expand('%:p')
            echo printf("File (%s): %s", &ft, expand('%:p'))
            let g:custom_last_display_file_path = expand('%:p')
        endif
    endif
endfunction

function! custom#lineInfosToggle()
    if ! exists("g:custom_line_infos_status")
        let g:custom_line_infos_status = 1
    endif

    if g:custom_line_infos_status == 0
        set number
        execute ':IndentLinesEnable'
        execute ':SignifyEnable'
        set signcolumn=auto
        let g:custom_line_infos_status = 1
    else
        set nonumber
        execute ':IndentLinesDisable'
        execute ':SignifyDisable'
        set signcolumn=no
        let g:custom_line_infos_status = 0
    endif
endfunction
