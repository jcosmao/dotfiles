"
" Plugins Install
"

" PlugInstall [name ...] [#threads] 	Install plugins
" PlugUpdate [name ...] [#threads] 	Install or update plugins
" PlugClean[!] 	Remove unused directories (bang version will clean without prompt)
" PlugUpgrade 	Upgrade vim-plug itself
" PlugStatus 	Check the status of plugins
" PlugDiff 	Examine changes from the previous update and the pending changes
" PlugSnapshot[!] [output path] 	Generate script for restoring the current snapshot of the plugins<Paste>

call plug#begin('~/.vim/plug')

" completion / linter

Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'ray-x/lsp_signature.nvim'
Plug 'folke/trouble.nvim'
Plug 'w0rp/ale'

" Utils

Plug 'mhinz/vim-startify'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', {'dir': '~/.fzf',
\                     'do': './install --no-update-rc --key-bindings --completion --xdg; cd  ~/.vim/plug/fzf.vim; patch -p1 -stNr /dev/null < ~/.vim/plugin_patch/fzf.vim.patch; true'}
Plug 'chengzeyi/fzf-preview.vim'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'Yggdroot/indentLine'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'yuttie/comfortable-motion.vim'
Plug 'troydm/zoomwintab.vim'
Plug 'Valloric/ListToggle'
Plug 'roxma/vim-paste-easy'
Plug 'junegunn/rainbow_parentheses.vim'
" breaking change - does not detect root pattern with priority
Plug 'airblade/vim-rooter', {'commit': 'd64f3e04df9914e784508019a1a1f291cbb40bd4'}

" Language Specific

" python completion
" Plug 'davidhalter/jedi-vim', {'for': 'python'}
" create .python{version} at the root project dir to force jedi to use
" this python version (useful to jump module from python path when there
" is both python2/3 in system)
" Plug 'jcosmao/jedi-vim-pyversion', {'for': 'python'}
" python syntax hilight
Plug 'numirias/semshi', {'for': 'python', 'do': ':UpdateRemotePlugins'}
Plug 'fatih/vim-go', {'for': 'go'}

" ctags / cscope

Plug 'ludovicchabant/vim-gutentags', {'do': 'cd  ~/.vim/plug/vim-gutentags; patch -p1 -stNr /dev/null < ~/.vim/plugin_patch/vim-gutentags.patch; true'}
Plug 'preservim/tagbar'

" git

Plug 'mhinz/vim-signify'
Plug 'rhysd/git-messenger.vim'

" Colorscheme

Plug 'sainnhe/gruvbox-material'
" Plug 'EdenEast/nightfox.nvim'

call plug#end()

"
" Common
"

set nocompatible
filetype off
filetype plugin indent on
syntax on
set ttyfast                         " Indicate fast terminal conn for faster redraw
set lazyredraw                      " Wait to redraw
set magic
set ruler                           " affiche la position du curseur en bas droite
set showmode                        " affiche le mode (insert ou autre)
set showcmd                         " Show current command.
set laststatus=2
set number
set cursorline
set signcolumn=auto
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set backspace=indent,eol,start      " activation de la touche backspace
set ai                              " autoindentation active
set sm                              " syntax match: soulignement d'une parenth e associ ,...
set hlsearch                        " colorisation de la recherche
set ts=4                            " taille des tabulations
set sw=4                            " taille des indentations
set tw=0                            " textwidth: largeur du texte (commentaires) 0=pas de limite
set expandtab                       " converti les tab en espaces
set directory=/tmp
set wildmode=full                   " vim bar autocomplete
set wildmenu
set smartindent
set autoread                        " Set vim to update autmatically when a file's read-only state is changed
set undodir=~/.cache/vim/undodir
set undofile                        " Persistent undo
set undolevels=10000                " maximum number of changes that can be undone
set undoreload=100000               " maximum number lines to save for undo on a buffer reload
set history=1000                    " remember more commands and search history
set nobackup                        " no backup or swap file, live dangerously
set noswapfile                      " swap files give annoying warning
set clipboard^=unnamedplus          " send yank to system clipboard
set updatetime=100
set hidden                          " Allow modified hidden buffers
set nofoldenable                    " Folding makes things unreadable.
set noautochdir

" Autocompletion
set shortmess+=c
set pumheight=20

" colorscheme
set termguicolors
set background=dark

" Load lua plugins config
if ! &readonly
    lua require('config')
endif

"
" Commands mapping
"

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
map <silent> <leader><ESC> :set nonumber \| :IndentLinesDisable \| :SignifyDisable \| :set signcolumn=no <cr>
map <silent> <leader><F1> :set number \| :IndentLinesEnable \| :SignifyEnable \| :set signcolumn=auto <cr>
map <silent> <F1> :NvimTreeToggle <cr>
map <silent> <F2> :TagbarToggle <cr>
map <silent> <F3> :IndentLinesToggle <cr>
map <silent> <F4> :set number! <cr>
map <silent> <F5> :SignifyToggle <cr>
map <silent> <F10> :set paste! <cr>
map <silent> <F11> :2,$s/^\s*pick/fixup/g <cr>
map <silent> <F12> :call custom#ToggleMouse() <cr>
map <silent> <leader>a :execute 'Rg' expand('<cword>') <cr>
map <silent> <leader>s :Rg <cr>
map <silent> <leader>f :Files <cr>
map <silent> <leader>b :Buffers <cr>
map <silent> <leader>d :Lines <cr>
map <silent> <leader>D :BLines <cr>
map <silent> <leader>t :FZFCtags <cr>
map <silent> <leader>c :BCommits <cr>
map <silent> <leader>h :History <cr>
map <silent> <leader>g :GitMessenger <cr>
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
map <silent> <leader><Up> :wincmd k<cr>
map <silent> <leader><Down> :wincmd j<cr>
map <silent> <leader><Right> :wincmd l<cr>
map <silent> <leader><Left> :wincmd h<cr>
map <silent> <leader><leader> :noh <cr>
map <silent> <leader><ENTER> :ZoomWinTabToggle <cr>
map <silent> <leader>k :TroubleToggle <cr>
map <silent> <leader>, <Plug>(ale_previous_wrap)
map <silent> <leader>. <Plug>(ale_next_wrap)
map <silent> <leader>< <Plug>(signify-prev-hunk)
map <silent> <leader>> <Plug>(signify-next-hunk)

" comfortable motion mapping
noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(40)<CR>
noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-40)<CR>
nnoremap <silent> <M-Down> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
nnoremap <silent> <M-Up> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>

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
