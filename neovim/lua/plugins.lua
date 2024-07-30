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
    {
        'windwp/nvim-autopairs',
        config = function()
            require("nvim-autopairs").setup {}
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
        config = function()
            require("neogen").setup({
                -- Enables Neogen capabilities
                enabled = true,
                -- Configuration for default languages
                languages = {},
                -- Use a snippet engine to generate annotations.
                snippet_engine = "luasnip",
                -- Enables placeholders when inserting annotation
                enable_placeholders = false,
            })
        end
    },
    {
        'ludovicchabant/vim-gutentags',
        cond = vim.fn.executable('ctags') == 1,
        build = function()
            PatchPlugin("vim-gutentags.patch")
        end,
        config = function()
            LoadVimscript("ctags_cscope.vim")
        end
    },

    -- git
    { 'lewis6991/gitsigns.nvim' },
    {
        'FabijanZulj/blame.nvim',
        config = function()
            require('blame').setup({
                date_format = "%d.%m.%Y",
                virtual_style = "right",
                views = {
                    window = window_view,
                    virtual = virtual_view,
                    default = window_view,
                },
                merge_consecutive = false,
                max_summary_width = 30,
                colors = nil,
                commit_detail_view = "vsplit",
                mappings = {
                    commit_info = "i",
                    stack_push = "<TAB>",
                    stack_pop = "<BS>",
                    show_commit = "<CR>",
                    close = { "<esc>", "q" },
                }
            })
        end
    },
    {
        'sindrets/diffview.nvim',
        config = function()
            local actions = require("diffview.actions")
            require("diffview").setup({
                keymaps = {
                    disable_defaults = false, -- Disable the default keymaps
                    view = {
                        -- The `view` bindings are active in the diff buffers, only when the current
                        -- tabpage is a Diffview.
                        { { "n", "i" }, "<F1>", actions.toggle_files, { desc = "Toggle the file panel." } },
                    },
                },
            })
        end
    },

    -- Colorscheme
    { 'sainnhe/gruvbox-material' },
    { 'catppuccin/nvim' },
    { 'norcalli/nvim-colorizer.lua' },
})
