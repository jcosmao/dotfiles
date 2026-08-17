# dotfiles

Personal configuration files for Unix-like systems.

## Usage

```bash
git clone --depth=1 https://github.com/jcosmao/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

## Includes

- Shell (zsh, bash) configs and scripts
- Tmux configuration
- Vim & Neovim setups
- Git configuration
- X11 preferences
- Custom scripts in `bin/`

## Neovim Plugins

Managed via [lazy.nvim](https://github.com/folke/lazy.nvim).

| Plugin | Purpose | Repository |
|--------|---------|------------|
| LuaSnip | Snippet engine | [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) |
| blame.nvim | Git blame | [FabijanZulj/blame.nvim](https://github.com/FabijanZulj/blame.nvim) |
| cinnamon.nvim | Smooth scrolling | [declancm/cinnamon.nvim](https://github.com/declancm/cinnamon.nvim) |
| cmp-buffer | Completion: buffer words | [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) |
| cmp-cmdline | Completion: cmdline | [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline) |
| cmp-nvim-lsp | Completion: LSP | [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) |
| cmp-nvim-lua | Completion: Lua API | [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua) |
| cmp-path | Completion: filesystem paths | [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path) |
| cmp-treesitter | Completion: treesitter | [ray-x/cmp-treesitter](https://github.com/ray-x/cmp-treesitter) |
| cmp_luasnip | Completion: LuaSnip | [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) |
| catppuccin | Colorscheme | [catppuccin/nvim](https://github.com/catppuccin/nvim) |
| diffview.nvim | Git diff viewer | [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) |
| friendly-snippets | Snippet collection | [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) |
| fzf | Fuzzy finder | [junegunn/fzf](https://github.com/junegunn/fzf) |
| fzf.vim | Fzf Vim integration | [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) |
| gitsigns.nvim | Git signs | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) |
| go.nvim | Go language support | [ray-x/go.nvim](https://github.com/ray-x/go.nvim) |
| guihua.lua | GUI helper | [ray-x/guihua.lua](https://github.com/ray-x/guihua.lua) |
| gruvbox-material | Colorscheme | [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material) |
| indent-blankline.nvim | Indent guides | [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) |
| lazy.nvim | Plugin manager | [folke/lazy.nvim](https://github.com/folke/lazy.nvim) |
| lsp_signature.nvim | LSP signature help | [ray-x/lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim) |
| lspkind-nvim | LSP kind icons | [onsails/lspkind.nvim](https://github.com/onsails/lspkind.nvim) |
| lualine.nvim | Statusline | [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) |
| mason-lspconfig.nvim | Mason LSP config | [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) |
| mason.nvim | LSP package manager | [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) |
| neogen | Doc generator | [danymat/neogen](https://github.com/danymat/neogen) |
| nvim | Neovim core | [neovim/neovim](https://github.com/neovim/neovim) |
| nvim-autopairs | Auto pairs | [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) |
| nvim-cmp | Completion engine | [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) |
| nvim-colorizer.lua | Color highlighter | [catgoose/nvim-colorizer.lua](https://github.com/catgoose/nvim-colorizer.lua) |
| nvim-lspconfig | LSP config | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) |
| nvim-surround | Surround text | [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround) |
| nvim-tree.lua | File tree | [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) |
| nvim-treesitter | Treesitter | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) |
| nvim-web-devicons | Icons | [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) |
| render-markdown.nvim | Markdown preview | [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) |
| statuscol.nvim | Status column | [luukvbaal/statuscol.nvim](https://github.com/luukvbaal/statuscol.nvim) |
| toggleterm.nvim | Terminal | [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) |
| trouble.nvim | Diagnostics | [folke/trouble.nvim](https://github.com/folke/trouble.nvim) |
| vim-commentary | Comment | [tpope/vim-commentary](https://github.com/tpope/vim-commentary) |
| vim-gutentags | Tags generator | [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags) |
| vim-puppet | Puppet support | [rodjek/vim-puppet](https://github.com/rodjek/vim-puppet) |
| vim-sensible | Sensible defaults | [tpope/vim-sensible](https://github.com/tpope/vim-sensible) |
| vim-startify | Start screen | [mhinz/vim-startify](https://github.com/mhinz/vim-startify) |
| vim-suda | Sudo write | [lambdalisue/vim-suda](https://github.com/lambdalisue/vim-suda) |
| zoomwintab.vim | Window zoom | [troydm/zoomwintab.vim](https://github.com/troydm/zoomwintab.vim) |
