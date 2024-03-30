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

if filereadable($HOME . '/.pyenv/versions/nvim/bin/python')
    let g:nvim_python_path = $HOME . '/.pyenv/versions/nvim/bin'
    let g:python3_host_prog = g:nvim_python_path . '/python'
    let $PATH =  g:nvim_python_path . ':' . $PATH
endif

let g:node_host_prog = $HOME . '/.local/bin/npm'

if !has('python3')
    echohl WarningMsg
    echo 'Missing python3 support - need to pip install pynvim'
    echohl None
endif

let g:plug_root = $HOME . '/.config/nvim/.plug'

call plug#begin(g:plug_root)

" completion / linter

Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'ojroques/nvim-lspfuzzy'
Plug 'ray-x/lsp_signature.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'ray-x/cmp-treesitter'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp'}
Plug 'rafamadriz/friendly-snippets'
Plug 'folke/trouble.nvim'

" Utils

if executable('gcc')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

Plug 'mhinz/vim-startify'
Plug 'nvim-tree/nvim-web-devicons'
" weird color bar appear on next commit
Plug 'nvim-tree/nvim-tree.lua', {'commit': 'f24afa2cef551122b8bd53bb2e4a7df42343ce2e'}
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'chengzeyi/fzf-preview.vim'
Plug 'itchyny/lightline.vim'
Plug 'josa42/nvim-lightline-lsp'
Plug 'Yggdroot/indentLine'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'psliwka/vim-smoothie'
Plug 'troydm/zoomwintab.vim'
" breaking change - does not detect root pattern with priority
Plug 'airblade/vim-rooter', {'commit': 'd64f3e04df9914e784508019a1a1f291cbb40bd4'}
Plug 'akinsho/toggleterm.nvim'

" Language Specific

" python syntax hilight
Plug 'wookayin/semshi', {'do': ':UpdateRemotePlugins'}
" nvim-go + deps
Plug 'ray-x/go.nvim', {'for': 'go'}
Plug 'ray-x/guihua.lua', {'for': 'go'}
" puppet
Plug 'rodjek/vim-puppet', {'for': 'puppet'}
" annotations (require nvim-treesitter)
Plug 'danymat/neogen'

" ctags / cscope
if executable('ctags')
    Plug 'dhananjaylatkar/cscope_maps.nvim'
    Plug 'ludovicchabant/vim-gutentags', {
    \    'do': 'cd ' . g:plug_root . '/vim-gutentags; patch -p1 -stNr /dev/null < ~/.config/nvim/plugin_patch/vim-gutentags.patch; git commit -am local; true'
    \}
endif

Plug 'stevearc/aerial.nvim'

" git
Plug 'mhinz/vim-signify'
Plug 'rhysd/git-messenger.vim'
Plug 'jcosmao/blame.nvim'
Plug 'sindrets/diffview.nvim'

" Colorscheme
Plug 'sainnhe/gruvbox-material'
Plug 'norcalli/nvim-colorizer.lua'

call plug#end()

"
" Common
"

set nocompatible
filetype off
filetype plugin indent on
syntax off
set mouse=
set ttyfast                         " Indicate fast terminal conn for faster redraw
set lazyredraw                      " Wait to redraw
set magic
set ruler                           " affiche la position du curseur en bas droite
set showmode                        " affiche le mode (insert ou autre)
set showcmd                         " Show current command.
set laststatus=2
set number
set cursorline
set cmdheight=2
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
set autowriteall
set nofoldenable                    " Folding makes things unreadable.
set noautochdir
set keymodel=startsel               " shift+arrow selection
set diffopt+=vertical               " start :diffsplit in vertical mode
set conceallevel=0                  " Do not interpret markdown for ex

" Autocompletion
set shortmess+=c
set pumheight=20

set termguicolors
if !empty("$THEME")
    exec 'set background='.$THEME
else
    set background=light
endif

let mapleader = " "   " Leader key set to <space bar>

" Load lua plugins config
if ! &readonly && has('python3')
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
map <silent> <leader>? :exec printf('view %s/help.md', fnamemodify(expand($MYVIMRC), ':p:h'))<cr>
map <silent> <leader>V :tabedit $MYVIMRC <cr>
map <silent> <leader>VV :source $MYVIMRC \| :echo $MYVIMRC 'reloaded' <cr>
map <silent> <leader><ESC> :call custom#lineInfosToggle() <cr>
map <silent> <F1> :NvimTreeFindFileToggle! <cr>
map <silent> <F2> :AerialToggle <cr>
map <silent> <F3> :IndentLinesToggle <cr>
map <silent> <F4> :set number! <cr>
map <silent> <F5> :SignifyToggle <cr>
map <silent> <F6> :set paste! <cr>
map <silent> <F9> :BackgroundToggle <cr>
map <silent> <F10> :Startify <cr>
map <silent> <F12> :call custom#ToggleMouse() <cr>
map <silent><expr> <leader>q empty(filter(getwininfo(), 'v:val.quickfix')) ? ":copen<cr>" : ":cclose<cr>"
map <silent> <leader>a :execute 'RgWithFilePath' expand('<cword>') <cr>
map <silent> <leader>A :execute 'Rg' expand('<cword>') <cr>
map <silent> <leader>s :RgWithFilePath <cr>
map <silent> <leader>S :Rg <cr>
map <silent> <leader>f :Files <cr>
map <silent> <leader>d :Neogen <cr>
map <silent> <leader>b :Buffers <cr>
map <silent> <leader>t :FZFCtags <cr>
map <silent> <leader>c :BCommits <cr>
map <silent> <leader>h :History <cr>
map <silent> <leader>g :execute 'ToggleBlame virtual' <cr>
map <silent> <leader>G :GitMessenger <cr>
map <silent> <leader>m :Snippets <cr>
map <silent> <C-a> ^
imap <silent> <C-a> <C-o>^
map <silent> <C-e> $
imap <silent> <C-e> <C-o>$
map <silent> <C-Right> e
map <silent> <C-Left> b
map <silent> <leader>+ :vsplit<cr>
map <silent> <leader>= :split <cr>
map <silent> <C-S-Up> :wincmd k<cr>
map <silent> <C-S-Down> :wincmd j<cr>
map <silent> <C-S-Right> :wincmd l<cr>
map <silent> <C-S-Left> :wincmd h<cr>
map <silent> <leader><Up> :wincmd k<cr>
map <silent> <leader><Down> :wincmd j<cr>
map <silent> <leader><Right> :wincmd l<cr>
map <silent> <leader><Left> :wincmd h<cr>
map <silent> <leader><leader> :noh <cr>
map <silent> <leader><ENTER> <C-w>o
map <silent> <leader>k :TroubleToggle document_diagnostics<cr>
map <silent> <leader>l :TroubleToggle workspace_diagnostics <cr>
" paste last yank (not from dd)
map <silent> <leader>p "0p
" vim surround
map <silent> <leader>" ysiW"
map <silent> <leader>: ysiw"
map <silent> <leader>' ysiW'
map <silent> <leader>; ysiw'

nnoremap <silent> <M-Up> <cmd>call smoothie#do("\<C-U>") <CR>
vnoremap <silent> <M-Up> <cmd>call smoothie#do("\<C-U>") <CR>
nnoremap <silent> <M-Down> <cmd>call smoothie#do("\<C-D>") <CR>
vnoremap <silent> <M-Down> <cmd>call smoothie#do("\<C-D>") <CR>

" Always forward with n / backward with N
noremap <expr> n (v:searchforward ? 'n' : 'N')
noremap <expr> N (v:searchforward ? 'N' : 'n')

" Tab
lua << EOF

local opts = { noremap = true, silent = true }
vim.keymap.set({'n', 'i'}, '<C-PageDown>', '<C-o>:tabprevious<CR>', opts)
vim.keymap.set({'n', 'i'}, '<S-PageDown>', '<C-o>:tabprevious<CR>', opts)
vim.keymap.set({'n', 'i'}, '<C-PageUp>', '<C-o>:tabnext<CR>', opts)
vim.keymap.set({'n', 'i'}, '<S-PageUp>', '<C-o>:tabnext<CR>', opts)
vim.keymap.set({'n', 'i'}, '<C-t>', '<C-o>:tabnew<CR>', opts)

EOF

for i in range(1, 9)
    execute "map <leader>" . i . " " . i . "gt"
endfor
map <leader>0 :tablast <cr>

nmap <leader>> <plug>(signify-next-hunk)
nmap <leader>< <plug>(signify-prev-hunk)

map <silent> <C-g> :ToggleTerm dir=%:p:h <cr>

" Specific filetype
autocmd BufNewFile,BufRead *.lib set filetype=sh
autocmd BufNewFile,BufRead *.source set filetype=sh
autocmd BufNewFile,BufRead *.pp set filetype=puppet
autocmd BufNewFile,BufRead *.inc set filetype=perl
autocmd BufNewFile,BufRead *.tf set filetype=terraform

autocmd WinEnter,BufWinEnter,FileWritePost,BufWritePost,BufRead * call custom#displayFilePath()

" remove auto<fucking>indent on colon :
autocmd FileType python,yaml setlocal indentkeys-=<:>
autocmd FileType python,yaml setlocal indentkeys-=:

augroup gomapping
    autocmd!
    autocmd FileType go nnoremap <silent> <leader><BS> :GoCodeLenAct<cr>
    autocmd FileType go nnoremap <silent> <leader>= :GoIfErr<cr>
augroup end

augroup indentlinesdisable
    autocmd!
    autocmd TermOpen * execute 'IndentLinesDisable'
    autocmd FileType markdown,json,yaml,join(g:custom_special_filtetypes, ",") execute 'IndentLinesDisable'
augroup end

" trim whitespace
autocmd BufWritePre * :%s/\s\+$//e
" save without trim
imap <silent> <C-s> <Esc>:noautocmd w <cr>
map <silent> <C-s> :noautocmd w <cr>
