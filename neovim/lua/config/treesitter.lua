local has, _ = pcall(require, 'nvim-treesitter')
if not has then
    return nil
end

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 20
vim.opt.foldnestmax = 10

require("nvim-treesitter.install").prefer_git = false
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"dockerfile", "c", "python", "rust", "latex", "yaml", "perl", "markdown", "go", "make", "http", "comment", "css", "javascript", "vim", "cmake", "ruby", "json", "regex", "lua", "cpp", "html", "rst", "hcl", "gomod", "bash", "toml", "diff", "terraform", "ini"},
   -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {},
  highlight = {
    enable = true,              -- false will disable the whole extension
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
