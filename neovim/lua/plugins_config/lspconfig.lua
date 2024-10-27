-- LSP Configuration & Plugins
local vim = vim
local _border = "rounded"

require("mason").setup({
    ui = {
        border = _border
    }
})

require('lspconfig.ui.windows').default_options.border = _border

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = _border
    }
)

-- display result in FZF
require('lspfuzzy').setup {
    methods = 'all',       -- either 'all' or a list of LSP methods (see below)
    jump_one = true,       -- jump immediately if there is only one location
    save_last = true,     -- save last location results for the :LspFuzzyLast command
    callback = nil,        -- callback called after jumping to a location
    fzf_modifier = ':~:.', -- format FZF entries, see |filename-modifiers|
    fzf_trim = true,       -- trim FZF entries
}

local signature_config = {
    log_path = vim.fn.expand("$HOME") .. "/.cache/vim_lsp_signature.log",
    debug = false,
    hint_enable = false,
    max_width = 80,
    doc_lines = 0,
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = _border
    },
    padding = ' ',
}

require("lsp_signature").setup(signature_config)

local virtual_text_default = {
    format = function(diagnostic)
        local lines = vim.split(diagnostic.message, '\n')
        return lines[1]
    end,
    virt_text_pos = 'right_align',
    suffix = ' ',
    prefix = "■",
    spacing = 10,
}

vim.diagnostic.config({
    underline = false,
    update_in_insert = true,
    float = {
        focusable = true,
        style = "minimal",
        border = _border,
        source = "always",
        header = "",
        prefix = "",
    },
    -- virtual_text = virtual_text_default,
    -- disable by default
    virtual_text = false,
})

-- display config
-- :lua = vim.diagnostic.config()
local function lspconfig_diagnostic_virtual_text_toggle()
    if not vim.diagnostic.config().virtual_text then
        vim.diagnostic.config({ virtual_text = virtual_text_default })
        vim.notify("diagnostic.virtual_text enabled")
    else
        vim.diagnostic.config({ virtual_text = false })
        vim.notify("diagnostic.virtual_text disabled")
    end
end

local function lspconfig_diagnostic_toggle()
    if vim.diagnostic.is_disabled() then
        vim.diagnostic.enable()
        vim.notify("diagnostic enabled")
    else
        vim.diagnostic.disable()
        vim.notify("diagnostic disabled")
    end
end

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end


local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>,', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>.', vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>j", function() lspconfig_diagnostic_virtual_text_toggle() end)
vim.keymap.set("n", "<leader>J", function() lspconfig_diagnostic_toggle() end)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- lsp (l)
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-\\>', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '?', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)
    vim.keymap.set('n', '<leader>u', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>i', vim.lsp.buf.implementation, opts)
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually, source: https://github.com/kevinhwang91/nvim-ufo
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}


local efm_cfg = require("plugins_config.efm")

local lsp = {
    bashls = {},
    basedpyright = {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "off",
                },
            },
        }
    },
    jsonls = {},
    yamlls = {},
    lua_ls = {},
    efm = {
        settings = efm_cfg.settings,
        filetypes = vim.tbl_keys(efm_cfg.settings.languages),
        init_options = { documentFormatting = true },
    },
    terraformls = {
        filetypes = { 'terraform' },
    },
    tflint = {
        filetypes = { 'terraform' },
    },
    ansiblels = {},
    eslint = {},
    gopls = {},
    puppet = {},
    volar = {
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'html' }
    },
    markdown_oxide = {
        filetypes = { 'markdown' },
    },

    -- shfmt = {},
    -- mypy = {},
    -- isort = {},
    -- prettierd = {},
    -- ["pyproject-flake8"] = {},
}

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(lsp),
    automatic_installation = true,
}

mason_lspconfig.setup_handlers {
    -- This is a default handler that will be called for each installed server (also for new servers that are installed during a session)
    function(server_name)
        local srv = lsp[server_name] or {}
        local settings = srv.settings or nil
        local filetypes = srv.filetypes or nil
        local init_options = srv.init_options or nil

        local lspconfig = require("lspconfig")
        lspconfig[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = settings,
            filetypes = filetypes,
            init_options = init_options,
        }
    end,
}
