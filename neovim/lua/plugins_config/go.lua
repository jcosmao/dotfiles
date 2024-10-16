local vim = vim

-- NOTE: all LSP and formatting related options are disabeld.
-- NOTE: LSP is handled by lsp.lua and formatting is handled by null-ls.lua
-- NOTE: via `lsp_on_attach` the custom callback used by all other LSPs is called
require("go").setup({
    go = "go",                 -- go command, can be go[default] or go1.18beta1
    fillstruct = "gopls",      -- can be nil (use fillstruct, slower) and gopls
    goimports = 'gopls',       -- goimports command, can be gopls[default] or either goimports or golines if need to split long lines
    gofmt = 'gopls',           -- gofmt through gopls: alternative is gofumpt, goimports, golines, gofmt, etc
    max_line_len = 0,          -- max line length in golines format, Target maximum line length for golines
    tag_transform = false,     -- tag_transfer  check gomodifytags for details
    test_template = "testify", -- default to testify if not set; g:go_nvim_tests_template  check gotests for details
    test_template_dir = "",    -- default to nil if not set; g:go_nvim_tests_template_dir  check gotests for details
    comment_placeholder = "",  -- comment_placeholder your cool placeholder e.g. ﳑ       
    icons = { breakpoint = "🧘", currentpos = "🏃" },
    verbose = false,           -- output loginf in messages
    lsp_cfg = false,           -- true: use non-default gopls setup specified in go/lsp.lua
    -- false: do nothing
    -- if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
    --   lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}}
    lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
    lsp_codelens = true, -- set to false to disable codelens, true by default
    lsp_keymaps = true,  -- set to false to disable gopls/lsp keymap
    lsp_document_formatting = true,
    -- set to true: use gopls to format
    -- false if you want to use other formatter tool(e.g. efm, nulls)
    lsp_inlay_hints = {
        enable = true,
        -- Only show inlay hints for the current line
        only_current_line = false,
        -- Event which triggers a refersh of the inlay hints.
        -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
        -- not that this may cause higher CPU usage.
        -- This option is only respected when only_current_line and
        -- autoSetHints both are true.
        only_current_line_autocmd = "CursorHold",
        -- whether to show variable name before type hints with the inlay hints or not
        -- default: false
        show_variable_name = true,
        -- prefix for parameter hints
        parameter_hints_prefix = " ",
        show_parameter_hints = true,
        -- prefix for all the other hints (type, chaining)
        other_hints_prefix = "=> ",
        -- whether to align to the length of the longest line in the file
        max_len_align = false,
        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,
        -- whether to align to the extreme right or not
        right_align = false,
        -- padding from the right if right_align is true
        right_align_padding = 6,
        -- The color of the hints
        highlight = "Comment",
    },
    gopls_cmd = nil,          -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
    gopls_remote_auto = true, -- add -remote=auto to gopls
    gocoverage_sign = "█",
    dap_debug = false,        -- set to false to disable dap
    dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    dap_debug_gui = true,     -- set to true to enable dap gui, highly recommended
    dap_debug_vt = true,      -- set to true to enable dap virtual text
    build_tags = "",          -- set default build tags
    textobjects = true,       -- enable default text jobects through treesittter-text-objects
    test_runner = "go",       -- richgo, go test, richgo, dlv, ginkgo
    run_in_floaterm = true,   -- set to true to run in float window.
    -- float term recommended if you use richgo/ginkgo with terminal color
    floaterm = {              -- position
        posititon = 'bottom', -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
        width = 1,            -- width of float window if not auto
        height = 0.3,         -- height of float window if not auto
    },
    luasnip = false,
})

-- Run gofmt + goimport on save
vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').goimport() ]], false)
