local vim = vim

local has, _ = pcall(require, 'nvim-treesitter')
if not has then
    return nil
end

require("nvim-treesitter.install").prefer_git = false
require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "bash",
        "go",
        "gomod",
        "c",
        "cpp",
        "python",
        "rust",
        "ruby",
        "perl",
        "vim",
        "html",
        "http",
        "css",
        "javascript",
        "lua",
        "json",
        "yaml",
        "markdown",
        "make",
        "cmake",
        "toml",
        "regex",
        "rst",
        "diff",
        "dockerfile",
        "terraform",
        "hcl",
        "ini",
        "comment",
        "vimdoc",
    },
    -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = {},
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = {},  -- list of language that will be disabled
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
        },
    },
}
