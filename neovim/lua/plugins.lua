local vim = vim
-- Plugin management
require("lazy-bootstrap")

local lazy = require("lazy")

require("lazy").setup({
    -- completion / linter
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'onsails/lspkind-nvim' },
    { 'ray-x/lsp_signature.nvim' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-nvim-lua' },
    {
        'ray-x/cmp-treesitter',
        config = function()
            require("nvim-treesitter.install").prefer_git = true
            opts = require('plugins_config.treesitter')
            require('nvim-treesitter.configs').setup(opts)
        end,
    },
    { 'saadparwaiz1/cmp_luasnip' },
    {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp'
    },
    { 'rafamadriz/friendly-snippets' },
    {
        'folke/trouble.nvim',
        opt = require("plugins_config.trouble"),
        config = function()
            require("trouble").setup()
        end
    },
    -- Utils
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        cond = vim.fn.executable('gcc') == 1
    },
    { 'mhinz/vim-startify' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-tree/nvim-tree.lua' },
    { 'junegunn/fzf' },
    { 'junegunn/fzf.vim' },
    { 'ojroques/nvim-lspfuzzy' },
    { 'nvim-lualine/lualine.nvim' },
    { 'akinsho/bufferline.nvim' },
    { 'lukas-reineke/indent-blankline.nvim' },
    {
        'windwp/nvim-autopairs',
        config = function()
            require("nvim-autopairs").setup({})
        end
    },
    { 'tpope/vim-sensible' },
    { 'tpope/vim-commentary' },
    { 'lambdalisue/vim-suda' },
    { 'psliwka/vim-smoothie' },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = require("plugins_config.render_markdown"),
        ft = { "markdown", "norg", "rmd", "org" },
    },

    { 'akinsho/toggleterm.nvim' },
    { 'troydm/zoomwintab.vim' },

    -- Language Specific
    {
        'ray-x/go.nvim',
        ft = 'go'
    },
    {
        'ray-x/guihua.lua',
        ft = 'go'
    },
    {
        'rodjek/vim-puppet',
        ft = 'puppet'
    },
    {
        'danymat/neogen',
        opts = require('plugins_config.neogen')
    },
    {
        'ludovicchabant/vim-gutentags',
        cond = vim.fn.executable('ctags') == 1,
        config = function()
            require("plugins_config.gutentags").setup()
        end,
        build = function()
            PatchPlugin("vim-gutentags.patch")
        end,
    },

    -- git
    { 'lewis6991/gitsigns.nvim' },
    {
        'FabijanZulj/blame.nvim',
        opts = require('plugins_config.blame')
    },
    {
        'sindrets/diffview.nvim',
        config = function()
            require('plugins_config.diffview').setup()
        end,
    },

    -- Colorscheme
    { 'sainnhe/gruvbox-material' },
    { 'catppuccin/nvim' },
    { 'norcalli/nvim-colorizer.lua' },
})
