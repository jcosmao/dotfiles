set nocompatible
filetype off
filetype plugin indent on
syntax on

set mouse=
set ttyfast                         " Indicate fast terminal conn for faster redraw
set lazyredraw                      " Wait to redraw
set magic
set ruler                           " affiche la position du curseur en bas droite
set showmode                        " affiche le mode (insert ou autre)
set showcmd                         " Show current command.
set laststatus=2
set number
set signcolumn=auto
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set backspace=indent,eol,start      " activation de la touche backspace
set ai                              " autoindentation active
set sm                              " syntax match: soulignement d'une parenth e associ ,...
set hlsearch                        " colorisation de la recherche
set ignorecase
set ts=4                            " taille des tabulations
set sw=4                            " taille des indentations
set tw=0                            " textwidth: largeur du texte (commentaires) 0=pas de limite
set expandtab                       " converti les tab en espaces
set directory=/tmp
set wildmode=full                   " vim bar autocomplete
set wildmenu
set smartindent
set autoread                        " Set vim to update autmatically when a file's read-only state is changed
set undodir=~/.cache/vim.lite/undodir
set undofile                        " Persistent undo
set undolevels=10000                " maximum number of changes that can be undone
set undoreload=100000               " maximum number lines to save for undo on a buffer reload
set history=1000                    " remember more commands and search history
set nobackup                        " no backup or swap file, live dangerously
set noswapfile                      " swap files give annoying warning
set clipboard^=unnamedplus          " send yank to system clipboard
set updatetime=100
set hidden                          " Allow modified hidden buffers
set autowriteall
set nofoldenable                    " Folding makes things unreadable.
set noautochdir
set keymodel=startsel               " shift+arrow selection
set nuw=6

" Autocompletion
set shortmess+=c
set pumheight=20

set timeoutlen=1000
set ttimeoutlen=100

" colorscheme
set notermguicolors                  " this fix mosh/tmux color
set background=light
set term=screen-256color
let g:gruvbox_contrast_light = "hard"
colorscheme gruvbox

" Remap some common typos
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>

" Mapping
let mapleader = " "   " Leader key set to <space bar>
map <silent> <leader>? :exec printf('view %s/help.md', fnamemodify(expand($MYVIMRC), ':p:h'))<cr>
map <silent> <leader>V :tabedit $MYVIMRC <cr>
map <silent> <leader>S :source $MYVIMRC \| :echo $MYVIMRC 'reloaded' <cr>
map <silent> <leader><ESC> :set nonumber \|  :set signcolumn=no <cr>
map <silent> <leader><F1> :set number \| :set signcolumn=auto <cr>
map <silent> <F1> :call ToggleNetrw()<CR>
map <silent> <F4> :set number! <cr>
map <silent> <F10> :set paste! <cr>
map <silent> <F12> :call custom#ToggleMouse() <cr>
map <silent> <C-a> ^
map <silent> <C-e> $
map <silent> <C-Right> e
map <silent> <C-Left> b
map <silent> <leader><bar> :vsplit<cr>
map <silent> <leader>\ :split <cr>
map <silent> <C-S-Up> :wincmd k<cr>
map <silent> <C-S-Down> :wincmd j<cr>
map <silent> <C-S-Right> :wincmd l<cr>
map <silent> <C-S-Left> :wincmd h<cr>
" https://vim.fandom.com/wiki/Fix_arrow_keys_that_display_A_B_C_D_on_remote_shell
map <silent> <leader><ESC>OA :wincmd k<cr>
map <silent> <leader><ESC>OB :wincmd j<cr>
map <silent> <leader><ESC>OC :wincmd l<cr>
map <silent> <leader><ESC>OD :wincmd h<cr>
map <silent> <leader><leader> :noh <cr>
map <silent> <leader><ENTER> <C-w>o
" paste last yank (not from dd)
map <silent> <leader>p "0p

" > cat
" ^[[1;3A     => M-Up
" ^[[1;3B     => M-Down
" ^[[1;5C     => C-Right
" ^[[1;5D     => C-Left
"
" ^[ == <Esc> or \e

noremap <silent> <Esc>[1;3A :-15 <CR>
noremap <silent> <Esc>[1;3B :+15 <CR>
inoremap <silent> <Esc>[1;3A <C-o>:-15 <CR>
inoremap <silent> <Esc>[1;3B <C-o>:+15 <CR>
noremap <silent> <Esc>[1;5C W
noremap <silent> <Esc>[1;5D B
inoremap <silent> <Esc>[1;5C <C-o>W
inoremap <silent> <Esc>[1;5D <C-o>B
noremap <silent> <Esc>[H ^
noremap <silent> <Esc>[F $
inoremap <silent> <Esc>[H <C-o>^
inoremap <silent> <Esc>[F <C-o>$
noremap <silent> <Esc>OH ^
noremap <silent> <Esc>OF $
inoremap <silent> <Esc>OH <C-o>^
inoremap <silent> <Esc>OF <C-o>$

" Always forward with n / backward with N
noremap <expr> n (v:searchforward ? 'n' : 'N')
noremap <expr> N (v:searchforward ? 'N' : 'n')

" Tab
map <C-PageDown> :tabprevious<CR>
map <C-PageUp>   :tabnext<CR>
map <C-t>        :tabnew<CR>

for i in range(1, 9)
    execute "map <leader>" . i . " " . i . "gt"
endfor
map <leader>0 :tablast <cr>

" Specific filetype
autocmd BufNewFile,BufRead *.lib set filetype=sh
autocmd BufNewFile,BufRead *.source set filetype=sh
autocmd BufNewFile,BufRead *.pp set filetype=puppet
autocmd BufNewFile,BufRead *.inc set filetype=perl

" trim whitespace
autocmd BufWritePre * :%s/\s\+$//e

" Enable Omnicomplete features - vim-auto-popmenu
set completeopt=longest,menuone,noinsert,noselect
let g:apc_enable_ft = {'text':1, 'markdown':1, 'sh':1, 'python':1, 'perl':1, 'puppet':1, 'ansible':1}    " enable filetypes
let g:apc_min_length = 2   " minimal length to open popup
let g:apc_key_ignore =  []  " ignore keywords

hi LineNr  term=underline ctermfg=181 guifg=#a89984
