" =============================================================================
" VIMRC LITE - Enhanced to be closer to Neovim config
" =============================================================================

" ----------------------------------------------------------------------------
" BASE SETTINGS
" ----------------------------------------------------------------------------
set nocompatible
filetype off
filetype plugin indent on
syntax on

" ----------------------------------------------------------------------------
" EDITOR BEHAVIOR
" ----------------------------------------------------------------------------
set mouse=
set ttyfast                         " Indicate fast terminal conn for faster redraw
set lazyredraw                      " Wait to redraw
set magic
set ruler                           " Show cursor position
set showmode                        " Show current mode
set showcmd                         " Show current command
set laststatus=2
set number
set signcolumn=auto
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set backspace=indent,eol,start      " Better backspace behavior
set autoindent                      " Auto-indent new lines
set smartindent
set hlsearch                        " Highlight search matches
set ignorecase
set smartcase                       " Case-sensitive if uppercase in search
set tabstop=4                       " Tab width
set shiftwidth=4                    " Indent width
set textwidth=0                     " No text width limit
set expandtab                       " Convert tabs to spaces
set directory=/tmp
set wildmode=full                   " Bash-like tab completion
set wildmenu
set autoread                        " Auto-reload files changed externally
set undodir=~/.cache/vim.lite/undodir
set undofile                        " Persistent undo
set undolevels=10000                " Max undo changes
set undoreload=100000              " Max lines for undo on buffer reload
set history=1000                    " Command history size
set nobackup
set noswapfile
set clipboard^=unnamedplus          " Sync with system clipboard
set updatetime=100
set hidden                          " Allow modified hidden buffers
set autowriteall                    " Auto-write on buffer switch
set nofoldenable                    " No folding by default
set noautochdir
set keymodel=startsel               " Shift+arrow selection
set numberwidth=6                  " Width of line number column

set cmdheight=2                     " Command line height
set conceallevel=0                  " Show all concealed characters
set diffopt+=vertical               " Vertical diff by default
set showtabline=2                   " Always show tab line
set pumheight=20                    " Popup menu height
set timeoutlen=1000                 " Timeout for mapped sequences
set ttimeoutlen=150                 " Timeout for terminal key codes
set termguicolors                   " Use GUI colors in terminal (if supported)

" ----------------------------------------------------------------------------
" COLORSCHEME
" ----------------------------------------------------------------------------
set notermguicolors                  " Fix for mosh/tmux color issues
set background=light
set term=screen-256color
let g:gruvbox_contrast_light = "hard"
colorscheme Tomorrow-Night

" ----------------------------------------------------------------------------
" PLUGIN SETTINGS (vim-auto-popmenu)
" ----------------------------------------------------------------------------
" Enable Omnicomplete features - vim-auto-popmenu
set completeopt=longest,menuone,noinsert,noselect
let g:apc_enable_ft = {'text':1, 'markdown':1, 'sh':1, 'python':1, 'perl':1, 'puppet':1, 'ansible':1}
let g:apc_min_length = 2
let g:apc_key_ignore =  []

" ----------------------------------------------------------------------------
" COMMAND ALIASES (Fix common typos)
" ----------------------------------------------------------------------------
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>

" ----------------------------------------------------------------------------
" SEARCH BEHAVIOR
" ----------------------------------------------------------------------------
" Always forward with n / backward with N
noremap <expr> n (v:searchforward ? 'n' : 'N')
noremap <expr> N (v:searchforward ? 'N' : 'n')

" Make # search forward like *
map <silent> # *

" ----------------------------------------------------------------------------
" KEYBINDINGS - LEADER / GENERAL
" ----------------------------------------------------------------------------
let mapleader = " "   " Leader key set to <space bar>

" Help and config
map <silent> <leader>? :exec printf('view %s/help.md', fnamemodify(expand($MYVIMRC), ':p:h'))<cr>
map <silent> <leader>V :tabedit $MYVIMRC <cr>
map <silent> <leader>S :source $MYVIMRC \| :echo $MYVIMRC 'reloaded' <cr>

" Toggle settings
map <silent> <leader><ESC> :set nonumber \| :set signcolumn=no <cr>
map <silent> <leader><F1> :set number \| :set signcolumn=auto <cr>
map <silent> <F1> :call ToggleNetrw()<CR>
map <silent> <F4> :set number! <cr>
map <silent> <F10> :set paste! <cr>
map <silent> <F12> :call ToggleMouse()<CR>
inoremap <silent> <F12> <Esc>:call ToggleMouse()<CR>a

" Clear highlights
map <silent> <leader><leader> :noh <cr>

" Close all windows except current
map <silent> <leader><ENTER> <C-w>o

" Paste from yank register (not from dd)
map <silent> <leader>p "0p

" ----------------------------------------------------------------------------
" KEYBINDINGS - NAVIGATION
" ----------------------------------------------------------------------------
" Move to start/end of line (like Ctrl+A / Ctrl+E in bash)
map <silent> <C-a> ^
map <silent> <C-e> $
imap <silent> <C-a> <C-o>^
imap <silent> <C-e> <C-o>$

" Word navigation (like Alt+Left/Right)
map <silent> <C-Right> e
map <silent> <C-Left> b
imap <silent> <C-Right> <C-o>e
imap <silent> <C-Left> <C-o>b

" Window navigation
map <silent> <leader><bar> :vsplit<cr>
map <silent> <leader>\ :split <cr>
map <silent> <C-S-Up> :wincmd k<cr>
map <silent> <C-S-Down> :wincmd j<cr>
map <silent> <C-S-Right> :wincmd l<cr>
map <silent> <C-S-Left> :wincmd h<cr>

" Terminal-compatible arrow keys fix (ESC[ sequences)
noremap <silent> <Esc>[1;3A :-15 <CR>
inoremap <silent> <Esc>[1;3A <C-o>:-15 <CR>
noremap <silent> <Esc>[1;3B :+15 <CR>
inoremap <silent> <Esc>[1;3B <C-o>:+15 <CR>
noremap <silent> <Esc>[1;5C W
inoremap <silent> <Esc>[1;5C <C-o>W
noremap <silent> <Esc>[1;5D B
inoremap <silent> <Esc>[1;5D <C-o>B
noremap <silent> <Esc>[1;5A :-5 <cr>
inoremap <silent> <Esc>[1;5A <C-o>:-5 <cr>
noremap <silent> <Esc>[1;5B :+2 <cr>
inoremap <silent> <Esc>[1;5B <C-o>:+2 <cr>

" Home / End - various terminal modes
noremap <silent> <Esc>[H ^
inoremap <silent> <Esc>[H <C-o>^
noremap <silent> <Esc>[F $
inoremap <silent> <Esc>[F <C-o>$
noremap <silent> <Esc>OH ^
inoremap <silent> <Esc>OH <C-o>^
noremap <silent> <Esc>OF $
inoremap <silent> <Esc>OF <C-o>$

" Fix arrow keys in insert mode
inoremap <silent> <Esc>OA <C-o>k
inoremap <silent> <Esc>OB <C-o>j
inoremap <silent> <Esc>OC <C-o>l
inoremap <silent> <Esc>OD <C-o>h
inoremap <silent> <Esc>OH <C-o>^
inoremap <silent> <Esc>OF <C-o>$

" https://vim.fandom.com/wiki/Fix_arrow_keys_that_display_A_B_C_D_on_remote_shell
map <silent> <leader><ESC>OA :wincmd k<cr>
map <silent> <leader><ESC>OB :wincmd j<cr>
map <silent> <leader><ESC>OC :wincmd l<cr>
map <silent> <leader><ESC>OD :wincmd h<cr>

" Shift+Insert and middle-click paste
nnoremap <S-Insert> :set paste<CR>"+p:set nopaste<CR>
inoremap <S-Insert> <C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR>

" ----------------------------------------------------------------------------
" KEYBINDINGS - TABS
" ----------------------------------------------------------------------------
map <C-PageDown> :tabprevious<CR>
map <C-PageUp>   :tabnext<CR>
map <C-t>        :tabnew<CR>

" Tab navigation with leader + number
for i in range(1, 9)
    execute "map <leader>" . i . " " . i . "gt"
endfor
map <leader>0 :tablast <cr>

" ----------------------------------------------------------------------------
" KEYBINDINGS - EDITING
" ----------------------------------------------------------------------------
" Save without trim
noremap <silent> <C-s> :noautocmd w<CR>
inoremap <silent> <C-s> <Esc>:noautocmd w<CR>a

" Insert mode: paste last yank
imap <silent> <C-p> <C-r>"

" Insert mode: better tab completion
imap <silent> <S-Tab> <C-d>

" ----------------------------------------------------------------------------
" KEYBINDINGS - SEARCH & REPLACE
" ----------------------------------------------------------------------------
" Rename current word (LSP-like)
noremap <leader>r :%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>

" Search current word forward/backward
noremap <leader>* :execute 'normal! /\<<C-r><C-w>\>\<CR>'<CR>
noremap <leader># :execute 'normal! ?\<<C-r><C-w>\>\<CR>'<CR>

" ----------------------------------------------------------------------------
" KEYBINDINGS - FILE EXPLORER (Netrw)
" ----------------------------------------------------------------------------
" Already handled by plugin/netrw.vim

" ----------------------------------------------------------------------------
" KEYBINDINGS - FZF-LIKE (if fzf.vim is installed)
" ----------------------------------------------------------------------------
" If fzf.vim is available, uncomment these:
" noremap <leader>f :Files<CR>
" noremap <leader>b :Buffers<CR>
" noremap <leader>t :Tags<CR>
" noremap <leader>s :Rg<CR>
" noremap <leader>h :History<CR>
" noremap <leader>H :History:<CR>
" noremap <leader>c :BCommits<CR>

" ----------------------------------------------------------------------------
" KEYBINDINGS - DIAGNOSTICS (approximation without LSP)
" ----------------------------------------------------------------------------
" Open/close quickfix list
noremap <silent> <leader>e :copen<CR>
noremap <silent> <leader>k :cprev<CR>
noremap <silent> <leader>j :cnext<CR>

" ----------------------------------------------------------------------------
" KEYBINDINGS - SCROLL
" ----------------------------------------------------------------------------
" Alt-based scrolling (if terminal supports it)
noremap <silent> <M-Up> <C-U>zz
noremap <silent> <M-Down> <C-D>zz
noremap <silent> <M-z> zt
noremap <silent> <M-x> zz
noremap <silent> <M-c> zb

" ----------------------------------------------------------------------------
" KEYBINDINGS - FOLD
" ----------------------------------------------------------------------------
" Basic fold mappings (if fold is enabled)
noremap <silent> <M-/> za
noremap <silent> <M-.> zA

" ----------------------------------------------------------------------------
" KEYBINDINGS - UNDO / REDO
" ----------------------------------------------------------------------------
noremap <silent> u :undo<CR>
noremap <silent> r :redo<CR>

" =============================================================================
" END OF CONFIG
" =============================================================================
