local tmpl_filetypes = { "gotmpl", "gohtmltmpl", "gotexttmpl" }
vim.treesitter.language.register("gotmpl", { "gohtmltmpl", "gotexttmpl" })

vim.treesitter.query.add_directive("inject-go-tmpl!", function(_, _, bufnr, _, metadata)
  local ft = vim.bo[bufnr].filetype
  if not vim.tbl_contains(tmpl_filetypes, ft) then return end

  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
  local ext = fname:match(".*%.(%a+)%.%a+$") or fname:match(".*%.(%a+)$")
  if not ext or ext == ft then return end

  -- ext → vim filetype (uses settings.lua rules + nvim defaults), then → treesitter parser
  local lang = vim.filetype.match({ filename = "x." .. ext }) or ext
  metadata["injection.language"] = vim.treesitter.language.get_lang(lang) or lang
end, {})

-- Authoritatively replace gotmpl injections so go.nvim's blanket html+javascript
-- injections (which use ;; extends) don't merge in.
vim.treesitter.query.set("gotmpl", "injections", [[
((text) @injection.content
  (#inject-go-tmpl!)
  (#set! injection.combined))

((comment) @injection.content
  (#set! injection.language "comment"))
]])



return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        cond = vim.fn.executable('gcc') == 1,
        config = function()
            require("nvim-treesitter.install").prefer_git = true
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    "bash",
                    "go",
                    "gotmpl",
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
                    "markdown_inline",
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
                    enable = true,                 -- false will disable the whole extension
                    disable = G.SpecialFiletypes, -- list of language that will be disabled
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
            })
        end,
    }
}
