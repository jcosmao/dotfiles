-- Plugin management
require("lazy-bootstrap")

local lazy = require("lazy")

require("lazy").setup({
    -- completion / linter
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'onsails/lspkind-nvim' },
    { 'ojroques/nvim-lspfuzzy' },
    { 'ray-x/lsp_signature.nvim' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'ray-x/cmp-treesitter' },
    { 'saadparwaiz1/cmp_luasnip' },
    {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp'
    },
    { 'rafamadriz/friendly-snippets' },
    { 'folke/trouble.nvim' },

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
    { 'chengzeyi/fzf-preview.vim' },
    { 'nvim-lualine/lualine.nvim' },
    { 'akinsho/bufferline.nvim' },
    { 'lukas-reineke/indent-blankline.nvim' },
    { 'windwp/nvim-autopairs' },
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
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup {
                detection_methods = { "pattern" },
                patterns = { ".project" },
                silent_chdir = false,
                scope_chdir = 'global',
            }
        end
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
    { 'danymat/neogen' },

    -- ctags / cscope
    {
        'dhananjaylatkar/cscope_maps.nvim',
        cond = vim.fn.executable('ctags') == 1,
    },
    {
        'ludovicchabant/vim-gutentags',
        cond = vim.fn.executable('ctags') == 1,
    },

    -- git
    { 'lewis6991/gitsigns.nvim' },
    { 'FabijanZulj/blame.nvim' },
    { 'sindrets/diffview.nvim' },

    -- Colorscheme
    { 'sainnhe/gruvbox-material' },
    { 'catppuccin/nvim' },
    { 'norcalli/nvim-colorizer.lua' },
})
