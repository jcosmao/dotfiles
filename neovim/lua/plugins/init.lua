function PatchPlugin(patch)
    local script = vim.fn.stdpath("config") .. "/lua/plugins/patch/patch.sh"
    vim.fn.system({ script, patch })
end

-- Plugin management
require("plugins.lazy-bootstrap")

require("lazy").setup({
    -- Colorscheme
    require("plugins.colorscheme").lazy_config(),

    -- lsp / completion / linter
    require("plugins.lsp"),
    require("plugins.cmp"),
    require("plugins.treesitter"),
    require("plugins.snippet"),
    require("plugins.trouble"),

    -- Interface
    require("plugins.startify"),
    require("plugins.nvimtree"),
    require("plugins.lualine"),
    require("plugins.indent_blankline"),
    require("plugins.statuscol"),
    { 'nvim-tree/nvim-web-devicons' },
    { 'troydm/zoomwintab.vim' },
    require('plugins.scrolling'),

    -- Utils
    { 'junegunn/fzf' },
    { 'junegunn/fzf.vim' },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
    { 'tpope/vim-sensible' },
    { 'tpope/vim-commentary' },
    { 'lambdalisue/vim-suda' },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = true
    },

    -- Terminal
    require("plugins.toggleterm"),

    -- Languages
    require("plugins.gutentags"),
    require("plugins.render_markdown"),
    require("plugins.go"),
    require("plugins.neogen"),
    {
        'rodjek/vim-puppet',
        ft = 'puppet'
    },

    -- git
    require("plugins.git"),
})
