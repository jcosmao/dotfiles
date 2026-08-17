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
local tmpl_filetypes = { "gotmpl", "gohtmltmpl", "gotexttmpl", "tpl", "tmpl" }
vim.treesitter.language.register("gotmpl", { "gohtmltmpl", "gotexttmpl" })

-- Determine the base (injected) vim filetype for a go-template buffer.
-- e.g. helm `templates/foo.yaml` (filetype gotmpl) → "yaml".
-- Returns nil when the buffer isn't a template or no base language applies.
local function injected_filetype(bufnr)
    local ft = vim.bo[bufnr].filetype
    if not vim.tbl_contains(tmpl_filetypes, ft) then return end

    local path = vim.api.nvim_buf_get_name(bufnr)
    local ext = path:match(".*%.(%a+)%.%a+$") or path:match(".*%.(%a+)$")
    if not ext then return end

    -- extension is itself a template (e.g. helm `_helpers.tpl`): inject yaml
    -- when the file is part of a helm chart, otherwise nothing to inject.
    if vim.tbl_contains(tmpl_filetypes, ext) then
        if IsHelmChart(vim.fs.dirname(path)) then return "yaml" end
        return
    end

    -- ext → vim filetype (uses settings.lua rules + nvim defaults)
    return vim.filetype.match({ filename = "x." .. ext }) or ext
end

vim.treesitter.query.add_directive("inject-go-tmpl!", function(_, _, bufnr, _, metadata)
    local lang = injected_filetype(bufnr)
    if not lang then return end

    -- vim filetype → treesitter parser
    metadata["injection.language"] = vim.treesitter.language.get_lang(lang) or lang
end, {})

-- The buffer filetype stays `gotmpl`, so the injected language's FileType
-- autocmds never fire. Re-apply the injected language's editor options on
-- top of the template buffer. Optional per-language overrides for prefs that
-- aren't runtime ftplugin defaults (e.g. yaml = 2-space indent).
local injected_lang_overrides = {
    yaml = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = tmpl_filetypes,
    callback = function(ev)
        local lang = injected_filetype(ev.buf)
        if not lang then return end

        -- Generic: load the language's standard ftplugin options (expandtab,
        -- comments, commentstring, indentkeys, formatoptions, …) WITHOUT
        -- firing user FileType autocmds (avoids e.g. go's gofmt-on-save).
        -- Skip indent/ so the gotmpl treesitter indentexpr is preserved.
        vim.b[ev.buf].did_ftplugin = nil
        vim.cmd("runtime! ftplugin/" .. lang .. ".vim ftplugin/" .. lang .. "_*.vim ftplugin/" .. lang .. "/*.vim")

        local override = injected_lang_overrides[lang]
        if override then override() end
    end,
})

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
