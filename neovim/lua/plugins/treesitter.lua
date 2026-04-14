local install_parser = {
    "bash",
    "go",
    "gotmpl",
    "gomod",
    "gowork",
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
}


-- Go template: inject language for syntax hilight
-- if file is named  file.ext.template_extension then inject filetype ext
-- if file is named  file.ext and is a go template (filetype foced) then inject filetype ext
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
        end,
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    if IsSpecialFiletype() then
                        return
                    end
                    -- Enable treesitter highlighting and disable regex syntax
                    pcall(vim.treesitter.start)
                    -- Enable treesitter-based indentation
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            local alreadyInstalled = require('nvim-treesitter.config').get_installed()
            local parsersToInstall = vim.iter(install_parser)
                :filter(function(parser)
                    return not vim.tbl_contains(alreadyInstalled, parser)
                end)
                :totable()
            require('nvim-treesitter').install(parsersToInstall)
        end,
    }
}
